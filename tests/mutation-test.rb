#!/usr/bin/env ruby
# frozen_string_literal: true

#
# Mutation test for tests/check-consistency.rb.
#
# Usage: ruby tests/mutation-test.rb
# Exit: 0 if the checker caught every seeded violation, 1 otherwise.
#
# WHAT THIS IS
#   A test of the test suite. It takes the records shipped in this repository,
#   injects one violation of a documented rule at a time, and confirms the
#   checker reports an error naming that rule.
#
# WHY IT EXISTS
#   A checker that passes everything is indistinguishable from a checker that
#   checks nothing. Every rule below was observed to fire at least once, so a
#   green run means the rules are load-bearing.
#
# WHAT IT DOES NOT DO
#   Prove the checker is complete. A rule absent from this list has not been
#   shown to fire. It also proves nothing about whether the underlying records
#   are good audits.

require "yaml"
require "open3"
require "tmpdir"

ROOT = File.expand_path("..", __dir__)

def load_records
  recs = []
  (Dir["#{ROOT}/examples/*.md"] + Dir["#{ROOT}/tests/*.md"]).sort.each do |file|
    text = File.read(file)
    text.scan(/^```yaml\n(.*?)^```/m) do |m|
      rec = YAML.safe_load(m[0], aliases: true)
      recs << [File.basename(file), rec] if rec.is_a?(Hash) && rec.key?("overall_result")
    end
  end
  recs
end

def find_objection(rec, id)
  rec["candidate_objections"].find { |o| o["id"] == id }
end

def retain_record(recs)
  recs.find { |_, r| r.dig("overall_result", "result") == "retain" && r["candidate_objections"].any? }
end

# Each mutation: name, rule expected to fire, and a lambda applying the change.
MUTATIONS = [
  ["R1 status/evidence mismatch", "R1",
   ->(r) { o = r["candidate_objections"].find { |x| %w[unsupported unresolved not_applicable].include?(x["status"]) }
           next unless o
           o["evidence_status"] = "supported" }],
  ["R2 supported with no evidence", "R2",
   ->(r) { o = r["candidate_objections"].first
           o["supporting_evidence"] = []
           o["status"] = "supported" if o["evidence_status"] == "supported" }],
  ["R3 unsupported carrying evidence", "R3",
   ->(r) { o = r["candidate_objections"].find { |x| x["status"] == "unsupported" }
           next unless o
           o["supporting_evidence"] = [{ "ref" => r.dig("evidence_boundary", "available_evidence").first["ref"] }] }],
  ["R4 unresolvable evidence ref", "R4",
   ->(r) { o = r["candidate_objections"].find { |x| x["supporting_evidence"].is_a?(Array) && !x["supporting_evidence"].empty? }
           next unless o
           o["supporting_evidence"] = [{ "ref" => "E-NOT-IN-BOUNDARY" }] }],
  ["R5 background knowledge supports", "R5",
   ->(r) { o = r["candidate_objections"].find { |x| x["basis"] == "background_knowledge" }
           next unless o
           o["supporting_evidence"] = [{ "ref" => r.dig("evidence_boundary", "available_evidence").first["ref"] }]
           o["status"] = "supported"
           o["evidence_status"] = "supported" }],
  ["R6 substantive problem without demonstration", "R6",
   ->(r) { o = r["candidate_objections"].first
           o["problem_status"] = "substantive_problem"
           o["evidence_status"] = "possible" }],
  ["R7 substantive problem marked immaterial", "R7",
   ->(r) { o = r["candidate_objections"].first
           o["problem_status"] = "substantive_problem"
           o["evidence_status"] = "demonstrated"
           o["materiality"] = "immaterial"
           o["decision_impact"] = "no_effect" }],
  ["R9 thin rationale", "R9",
   ->(r) { r["candidate_objections"].first["rationale"] = "Unclear." }],
  ["R10 revise without the full chain", "R10",
   ->(r) { o = r["candidate_objections"].first
           o["decision_impact"] = "revise" }],
  ["R11 high confidence on absent evidence", "R11",
   ->(r) { o = r["candidate_objections"].first
           o["confidence"] = "high"
           o["supporting_evidence"] = []
           o["contradicting_evidence"] = []
           o["evidence_status"] = "possible" }],
  ["R12 retain stated as validation", "R12",
   ->(r) { next unless r.dig("overall_result", "result") == "retain"
           r["overall_result"]["statement"] = "The claim is validated." }],
  ["R12 retain drops the null phrasing", "R12",
   ->(r) { next unless r.dig("overall_result", "result") == "retain"
           r["overall_result"]["statement"] = "Nothing of substance was contested here." }],
  ["4.1 unsupported early exit without clarifications", "4.1",
   ->(r) { next unless r.dig("overall_result", "result") == "underspecified_claim"
           r.delete("clarifications_required") }],
  ["4.3 missing disclosure", "4.3",
   ->(r) { r["independence"] = {} }],
  ["4.4 invented error rate without ground truth", "4.4",
   ->(r) { r["evaluator_error_rate"] = r["evaluator_error"] = { "ground_truth_available" => false,
                                                                 "ground_truth_source" => nil,
                                                                 "evaluator_error_rate" => "0.92" } }],
  ["4.3 independence claimed with no ground truth", "4.3",
   ->(r) { r["independence"]["independent_judgments"] = true }],
  ["aggregate retain with a revise objection", "aggregate",
   ->(r) { next unless r.dig("overall_result", "result") == "retain"
           r["candidate_objections"].first["decision_impact"] = "revise" }],
  ["expectation disagrees with record", "expectation",
   nil] # handled specially below
].freeze

recs = load_records
abort "no records found" if recs.empty?

tmp = File.join(Dir.tmpdir, "claimcheck-mutation.md")
results = []

# Find the first record a mutation actually applies to, rather than assuming
# the first record in the repository is suitable for every rule.
def applicable(recs, mutate)
  recs.each do |file, original|
    rec = Marshal.load(Marshal.dump(original))
    before = Marshal.dump(rec)
    mutate.call(rec)
    return [file, rec] unless Marshal.dump(rec) == before
  end
  nil
end

MUTATIONS.each do |name, rule, mutate|
  if name == "expectation disagrees with record"
    # Rewrite a test's Expected table so it documents a different status, then
    # confirm the checker notices the disagreement with the shipped record.
    src = nil
    Dir["#{ROOT}/tests/*.md"].sort.each do |f|
      t = File.read(f)
      m = t[/^```yaml\n(.*?)^```/m, 1]
      next unless m

      rec = YAML.safe_load(m, aliases: true)
      next unless rec.is_a?(Hash) && rec["overall_result"]

      mutated = t.sub(/(\| O1 [^|]*\| `)(supported|contradicted|unsupported|unresolved|not_applicable)(`)/) do
        mm = Regexp.last_match
        wanted = { "supported" => "contradicted", "contradicted" => "supported",
                   "unsupported" => "supported", "unresolved" => "supported",
                   "not_applicable" => "supported" }[mm[2]] || "supported"
        "#{mm[1]}#{wanted}#{mm[3]}"
      end
      next if mutated == t

      File.write(tmp, mutated)
      out, st = Open3.capture2e("ruby", "#{ROOT}/tests/check-consistency.rb", tmp)
      ok = st.exitstatus != 0 && out.match?(/^\s+\S+\s+expectation\s/m)
      src = [ok, out.lines.grep(/expectation/).first.to_s.strip, f]
      break
    end
    if src.nil?
      results << [name, rule, false, "no Expected-table row found to mutate"]
    else
      results << [name, rule, src[0], src[0] ? "" : src[1], src[2]]
    end
    next
  end

  hit = applicable(recs, mutate)
  if hit.nil?
    results << [name, rule, false, "no record in the repository this mutation applies to"]
    next
  end

  file, rec = hit
  File.write(tmp, "```yaml\n#{rec.to_yaml}```\n")
  out, st = Open3.capture2e("ruby", "#{ROOT}/tests/check-consistency.rb", tmp)
  caught = st.exitstatus != 0 && out.match?(/^\s+\S+\s+#{Regexp.escape(rule)}\s/m)
  detail = out.lines.grep(/^\s+\S+\s+#{Regexp.escape(rule)}\s/).first.to_s.strip
  results << [name, rule, caught, caught ? "" : detail, file]
end

File.delete(tmp) if File.exist?(tmp)

puts "claimcheck :: mutation test"
puts "records available: #{recs.length}"
puts
results.each do |name, rule, ok, detail, file|
  puts format("  %-6s %-46s %-12s %-22s %s", ok ? "CAUGHT" : "MISSED", name, rule,
              file.to_s, detail.empty? ? "" : detail)
end
missed = results.count { |r| !r[2] }
puts
puts(missed.zero? ? "PASSED: every seeded violation was caught." : "FAILED: #{missed} mutation(s) slipped through.")
exit(missed.zero? ? 0 : 1)