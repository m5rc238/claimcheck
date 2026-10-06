#!/usr/bin/env ruby
# frozen_string_literal: true

#
# Consistency checker for critique records.
#
# Usage: ruby tests/check-consistency.rb [file ...]
#   With no arguments, checks every fenced yaml record in examples/ and tests/,
#   plus README.md. A fenced block is treated as a full record only when it
#   contains an `overall_result` key; illustrative fragments are skipped.
#
# Two layers:
#   1. Schema coherence. Permitted values, required fields, and the consistency
#      rules R1-R13 from schema.md.
#   2. Expectation agreement. For files under tests/, the classification each
#      test documents in its "## Expected" table must match the record it
#      ships. A test whose prose and record disagree is worse than no test.
#
# Exit: 0 no errors, 1 errors found, 2 usage or setup error.
#
# WHAT THIS CANNOT CHECK
#   Whether a judgment was right. Nothing here can tell you an objection should
#   have been `supported`, whether materiality was correctly assigned, or
#   whether the evidence boundary matches what was actually supplied. It checks
#   that a record which says `supported` carries evidence, not that the evidence
#   warrants it. A record can be fully consistent here and still be a bad audit,
#   and these tests are hand-built examples, not a sample of anything.
#
#   Warnings are heuristics that flag a place worth reading, not violations.

require "yaml"
require "set"

ERRORS = []
WARNINGS = []

def err(file, rule, msg)
  ERRORS << [file, rule, msg]
end

def warn_at(file, rule, msg)
  WARNINGS << [file, rule, msg]
end

ALLOWED = {
  "status" => %w[supported contradicted unsupported unresolved not_applicable],
  "evidence_status" => %w[demonstrated supported possible unknown],
  "problem_status" => %w[substantive_problem meaningful_risk minor_limitation
                         no_demonstrated_problem],
  "materiality" => %w[material potentially_material immaterial],
  "decision_impact" => %w[revise investigate retain no_effect],
  "confidence" => %w[low medium high],
  "basis" => %w[supplied_evidence background_knowledge mixed],
  "result" => %w[revise investigate retain uncertain underspecified_claim],
  "formalization_status" => %w[sufficient underspecified]
}.freeze

# R1 - status pins the permitted evidence_status values.
R1 = {
  "supported" => %w[demonstrated supported],
  "contradicted" => %w[demonstrated supported],
  "unsupported" => %w[possible unknown],
  "unresolved" => %w[unknown],
  "not_applicable" => %w[unknown]
}.freeze

REQUIRED_CLAIM_KEYS = %w[
  original subject predicate scope population timeframe baseline
  intended_interpretation dependent_decision missing_definitions
  load_bearing_assumptions formalization_status
].freeze

REQUIRED_TOP_KEYS = %w[
  claim scope evidence_boundary candidate_objections overall_result
  evaluator_error independence limitations
].freeze

REQUIRED_OBJECTION_KEYS = %w[
  objection why_it_might_matter basis supporting_evidence
  contradicting_evidence resolution_test inapplicability_condition status
  evidence_status problem_status materiality decision_impact confidence rationale
].freeze

# R12 - validation language barred from a retain statement.
BANNED_RETAIN_WORDS = %w[
  proven proves validate validated confirms confirmed verifies verified correct
  true accurate flawless definitively
].freeze

BANNED_RETAIN_PHRASES = ["no issue found", "beyond doubt"].freeze

CONSEQUENCE_MARKERS = %w[would consequence if changes].freeze

# Phrases that imply validation without tripping R12's word list. Multi-word on
# purpose: single words such as "no" or "up" fire on legitimate text.
RETAIN_PARAPHRASES = [
  "holds up", "hold up", "survived scrutiny", "survives scrutiny",
  "stood up to", "stands up to", "withstood", "stood the test",
  "nothing suggests otherwise", "nothing of concern",
  "no objection stands", "no objections stand", "no issues found",
  "in good shape", "is safe to rely", "safe to rely on"
].freeze

# A disclosure must convey that the passes were not independent judgments.
DISCLOSURE_TERMS = /correlat|independent|one model|same model|second model|shared/i

def blank?(v)
  v.nil? || (v.respond_to?(:empty?) && v.empty?)
end

def list(v)
  v.is_a?(Array) ? v : []
end

def refs(evidence)
  list(evidence).map { |item| item.is_a?(Hash) ? item["ref"] : item }.compact
end

def permitted?(field, value)
  ALLOWED[field].include?(value)
end

def check_permitted(file, obj, field)
  value = obj[field]
  return if permitted?(field, value)

  err(file, "value", "#{obj['id'] || 'record'}: #{field} is #{value.inspect}, " \
                "permitted values are #{ALLOWED[field].join(', ')}")
end

# --- per-record checks -----------------------------------------------------

def check_record(file, rec)
  REQUIRED_TOP_KEYS.each do |k|
    err(file, "structure", "missing top-level key #{k}") unless rec.key?(k)
  end
  return if rec["claim"].nil? || rec["candidate_objections"].nil?

  check_claim(file, rec)
  boundary = check_boundary(file, rec)
  objections = list(rec["candidate_objections"])
  objections.each_with_index { |o, i| check_objection(file, o, i, boundary) }
  check_aggregations(file, rec, objections)
  check_disclosures(file, rec)
end

def check_claim(file, rec)
  claim = rec["claim"]
  REQUIRED_CLAIM_KEYS.each do |k|
    err(file, "structure", "claim: missing key #{k}") unless claim.key?(k)
  end
  %w[missing_definitions load_bearing_assumptions].each do |k|
    next if claim[k].nil? || claim[k].is_a?(Array)

    err(file, "structure", "claim: #{k} must be a list")
  end
  check_permitted(file, claim, "formalization_status")
end

# Returns the set of refs available in the boundary.
def check_boundary(file, rec)
  boundary = rec["evidence_boundary"] || {}
  available = list(boundary["available_evidence"])
  unless %w[authorized attempted unavailable not_authorized].include?(boundary["external_research"])
    err(file, "value", "evidence_boundary.external_research is " \
                      "#{boundary['external_research'].inspect}, not a permitted value")
  end
  return Set.new if available.empty?

  bk = boundary["background_knowledge"]
  if bk.is_a?(Hash) && bk["role"] != "hypothesis_generation_only"
    warn_at(file, "R5", "background_knowledge.role is #{bk['role'].inspect}; " \
                        "schema fixes it to hypothesis_generation_only")
  end

  seen = []
  available.each do |item|
    next unless item.is_a?(Hash)

    seen << item["ref"]
    %w[type locator content].each do |k|
      err(file, "structure", "evidence_boundary: entry #{item['ref'].inspect} missing #{k}") if blank?(item[k])
    end
  end
  dupes = seen.select { |r| seen.count(r) > 1 }.uniq
  err(file, "R4", "evidence_boundary contains duplicate refs: #{dupes.join(', ')}") unless dupes.empty?
  Set.new(seen)
end

def check_objection(file, obj, index, boundary)
  id = obj["id"] || "objection[#{index}]"

  REQUIRED_OBJECTION_KEYS.each do |k|
    err(file, "structure", "#{id}: missing key #{k}") unless obj.key?(k)
  end

  %w[status evidence_status problem_status materiality decision_impact confidence basis].each do |f|
    check_permitted(file, obj, f)
  end

  # R9 - required prose fields are present and substantive.
  %w[objection why_it_might_matter resolution_test inapplicability_condition].each do |f|
    err(file, "R9", "#{id}: #{f} is empty") if obj.key?(f) && blank?(obj[f])
  end
  if obj["rationale"] && obj["rationale"].split.length < 12
    err(file, "R9", "#{id}: rationale has #{obj['rationale'].split.length} words, " \
                    "minimum is 12; one-word rationales pass review unnoticed")
  end

  sup = refs(obj["supporting_evidence"])
  con = refs(obj["contradicting_evidence"])
  status = obj["status"]

  # R2 - a supported or contradicted verdict requires its evidence.
  err(file, "R2", "#{id}: status supported with empty supporting_evidence") if status == "supported" && sup.empty?
  err(file, "R2", "#{id}: status contradicted with empty contradicting_evidence") if status == "contradicted" && con.empty?

  # R3 - an unsupported verdict must not carry supporting evidence.
  if status == "unsupported" && !sup.empty?
    err(file, "R3", "#{id}: status unsupported but supporting_evidence is not empty")
  end

  # R1 - status pins evidence_status.
  if status && obj["evidence_status"] && !R1.fetch(status, []).include?(obj["evidence_status"])
    err(file, "R1", "#{id}: status #{status} permits evidence_status " \
                    "#{R1[status].join(' or ')}, found #{obj['evidence_status']}")
  end

  # R4 - every cited ref must exist in the boundary.
  (sup + con).each do |r|
    err(file, "R4", "#{id}: cites ref #{r.inspect}, which is not in evidence_boundary") unless boundary.include?(r)
  end

  # R5 - background knowledge may generate an objection, never support one.
  case obj["basis"]
  when "background_knowledge"
    unless sup.empty?
      err(file, "R5", "#{id}: basis is background_knowledge but supporting_evidence is " \
                      "not empty; background knowledge may generate an objection, not support one")
    end
  when "mixed"
    err(file, "R5", "#{id}: basis is mixed but supporting_evidence is empty") if sup.empty?
  when "supplied_evidence"
    err(file, "R5", "#{id}: basis is supplied_evidence but no evidence is cited") if sup.empty? && con.empty?
  end

  # R6 - a substantive problem requires demonstration.
  if obj["problem_status"] == "substantive_problem" && obj["evidence_status"] != "demonstrated"
    err(file, "R6", "#{id}: problem_status substantive_problem requires " \
                    "evidence_status demonstrated, found #{obj['evidence_status']}")
  end

  # R7 - a substantive problem cannot be immaterial. Note that evidence_status
  # demonstrated does NOT imply materiality material: a contradicted objection is
  # demonstrated and routinely immaterial.
  if obj["problem_status"] == "substantive_problem" && obj["materiality"] == "immaterial"
    err(file, "R7", "#{id}: problem_status substantive_problem with materiality immaterial")
  end
  if obj["materiality"] == "immaterial" && !%w[retain no_effect].include?(obj["decision_impact"].to_s)
    err(file, "R7", "#{id}: materiality immaterial with decision_impact " \
                    "#{obj['decision_impact']}; immaterial findings do not warrant action")
  end

  # R8 - materiality needs a stated counterfactual (heuristic).
  if obj["materiality"] == "material"
    text = obj["rationale"].to_s.downcase
    unless CONSEQUENCE_MARKERS.any? { |m| text.include?(m) }
      warn_at(file, "R8", "#{id}: materiality material; rationale names no consequence " \
                          "marker, so the counterfactual requirement needs a human read")
    end
  end

  # R10 - revise requires the full chain.
  if obj["decision_impact"] == "revise"
    err(file, "R10", "#{id}: decision_impact revise but status is #{status}") unless status == "supported"
    unless obj["problem_status"] == "substantive_problem"
      err(file, "R10", "#{id}: decision_impact revise but problem_status is #{obj['problem_status']}")
    end
    err(file, "R10", "#{id}: decision_impact revise but materiality is #{obj['materiality']}") unless obj["materiality"] == "material"
  end

  # R11 - confidence is bounded by evidence.
  if obj["confidence"] == "high"
    unless %w[demonstrated supported].include?(obj["evidence_status"])
      err(file, "R11", "#{id}: confidence high with evidence_status #{obj['evidence_status']}")
    end
    err(file, "R11", "#{id}: confidence high with no evidence cited") if sup.empty? && con.empty?
  end

  # R13 - not_applicable implies no bearing on the claim.
  if status == "not_applicable"
    { "materiality" => "immaterial",
      "decision_impact" => "no_effect",
      "problem_status" => "no_demonstrated_problem" }.each do |field, required|
      next if obj[field] == required

      err(file, "R13", "#{id}: status not_applicable requires #{field} #{required}, found #{obj[field]}")
    end
  end
end

def check_aggregations(file, rec, objections)
  overall = rec["overall_result"] || {}
  result = overall["result"]

  unless permitted?("result", result)
    err(file, "value", "overall_result.result is #{result.inspect}")
    return
  end

  impacts = objections.map { |o| o["decision_impact"] }
  has_revise = impacts.include?("revise")
  has_investigate = impacts.include?("investigate")

  case result
  when "revise"
    err(file, "aggregate", "overall revise but no objection has decision_impact revise") unless has_revise
  when "investigate"
    err(file, "aggregate", "overall investigate but no objection has decision_impact investigate") unless has_investigate
    err(file, "aggregate", "overall investigate while an objection has decision_impact revise") if has_revise
  when "retain"
    err(file, "aggregate", "overall retain but an objection has decision_impact revise") if has_revise
    err(file, "aggregate", "overall retain but an objection has decision_impact investigate") if has_investigate
  when "underspecified_claim"
    st = rec.dig("claim", "formalization_status")
    err(file, "aggregate", "overall underspecified_claim but claim.formalization_status is #{st}") unless st == "underspecified"
    unless objections.empty?
      err(file, "aggregate", "overall underspecified_claim but #{objections.length} objection(s) " \
                             "were generated; the stop rule forbids this")
    end
    clar = rec["clarifications_required"]
    err(file, "4.1", "overall underspecified_claim without clarifications_required") if list(clar).empty?
  end

  if !rec["clarifications_required"].nil? && result != "underspecified_claim"
    err(file, "4.1", "clarifications_required present on a record whose result is #{result}")
  end

  statement = overall["statement"].to_s
  err(file, "structure", "overall_result.statement is empty") if blank?(statement)

  # R12 - retain forbids validation language.
  if result == "retain"
    unless statement.downcase.include?("no supported problem identified")
      err(file, "R12", "retain statement must contain the mandated null phrasing " \
                       "'No supported problem identified from the available evidence'")
    end
    hit = BANNED_RETAIN_WORDS.find { |w| statement.match?(/\b#{Regexp.escape(w)}\b/i) }
    err(file, "R12", "retain statement contains validation language: #{hit.inspect}") if hit
    phrase = BANNED_RETAIN_PHRASES.find { |p| statement.downcase.include?(p) }
    err(file, "R12", "retain statement contains banned phrase: #{phrase.inspect}") if phrase
    RETAIN_PARAPHRASES.each do |phrase|
      next unless statement.downcase.include?(phrase)

      warn_at(file, "R12", "retain statement contains #{phrase.inspect}, which implies " \
                          "validation by paraphrase; a phrase the checker has not thought " \
                          "of will pass silently, so read the statement")
    end
  end

  list(overall["objections_supporting_result"]).each do |oid|
    next if objections.any? { |o| o["id"] == oid }

    err(file, "aggregate", "overall_result references unknown objection id #{oid.inspect}")
  end

  err(file, "structure", "overall_result.basis is empty") if list(overall["basis"]).empty?
end

def check_disclosures(file, rec)
  ee = rec["evaluator_error"] || {}

  if ee["ground_truth_available"] == true && blank?(ee["ground_truth_source"])
    err(file, "4.4", "ground_truth_available is true but ground_truth_source is empty")
  end

  rate = ee["evaluator_error_rate"].to_s
  if ee["ground_truth_available"] != true && !rate.include?("evaluator_error_rate_not_determinable")
    err(file, "4.4", "without ground truth, evaluator_error_rate must be " \
                     "evaluator_error_rate_not_determinable, found #{rate.inspect}")
  end

  indep = rec["independence"] || {}

  if indep["independent_judgments"] == true
    if ee["ground_truth_available"] != true
      err(file, "4.3", "independent_judgments is true with no ground truth; model passes are " \
                       "correlated and a second model is not an oracle")
    end
    warn_at(file, "4.3", "independent_judgments is true; confirm the named ground truth " \
                        "source was actually part of the audit")
  end

  if blank?(indep["disclosure"])
    err(file, "4.3", "independence.disclosure is empty; every run must disclose correlated-error limits")
  elsif !indep["disclosure"].match?(DISCLOSURE_TERMS)
    err(file, "4.3", "independence.disclosure does not convey that the passes were not " \
                     "independent judgments")
  end

  err(file, "4.3", "independence.passes_performed is empty") if list(indep["passes_performed"]).empty?
  err(file, "structure", "limitations is empty; every run must record its limits") if list(rec["limitations"]).empty?
end

# --- expectation agreement -------------------------------------------------
#
# A test documents what it expects in a markdown table under "## Expected".
# That table must agree with the record the test ships, or the test is theatre.

FIELD_FOR_COLUMN = {
  "status" => :status,
  "evidence_status" => :evidence_status,
  "problem_status" => :problem_status,
  "materiality" => :materiality,
  "decision_impact" => :decision_impact
}.freeze

def cells(line)
  line.strip.sub(/\A\|/, "").sub(/\|\z/, "").split("|").map(&:strip)
end

def backtick(cell)
  m = cell.match(/`([^`]+)`/)
  m && m[1]
end

def check_expectations(file, text, rec, strict: false)
  section = text[/^##\s+Expected\s*$(.*?)(?=^##\s|\z)/m, 1]
  if section.nil?
    if strict
      warn_at(file, "expectation", "no '## Expected' section; a test that does not " \
                                   "document its expected classifications cannot be checked")
    end
    return
  end

  rows = section.lines.select { |l| l.strip.start_with?("|") }.map { |l| cells(l) }
  rows.reject! { |r| r.all? { |c| c.match?(/\A:?-{2,}:?\z/) } }
  return if rows.empty?

  header = rows.shift.map { |c| c.gsub("`", "").strip }
  objections = list(rec["candidate_objections"])
  by_id = objections.each_with_object({}) { |o, h| h[o["id"]] = o }

  # Column index for each objection field, if the table has one.
  col_for = {}
  header.each_with_index do |h, i|
    key = FIELD_FOR_COLUMN[h]
    col_for[key] = i if key
  end

  saw_any = false

  rows.each do |row|
    first = backtick(row[0]) || row[0].to_s.gsub("`", "").strip

    # Row describing one objection: | O1 something | status | evidence_status | ...
    if (m = first.match(/\b(O\d+)\b/)) && !col_for.empty?
      saw_any = true
      oid = m[1]
      obj = by_id[oid]
      if obj.nil?
        err(file, "expectation", "expects objection #{oid}, which the record does not contain")
        next
      end
      col_for.each do |field, idx|
        cell = row[idx]
        next if cell.nil?

        want = backtick(cell)
        next if want.nil?

        got = obj[field.to_s]
        next if want == got

        err(file, "expectation", "#{oid} #{field}: test documents #{want.inspect}, record has #{got.inspect}")
      end
      next
    end

    # Two-column table: | `overall_result.result` | `underspecified_claim` |
    if row.length == 2
      want = backtick(row[1])
      case first
      when "overall_result.result"
        saw_any = true
        got = rec.dig("overall_result", "result")
        err(file, "expectation", "documents overall result #{want.inspect}, record has #{got.inspect}") if want && want != got
      when "claim.formalization_status"
        saw_any = true
        got = rec.dig("claim", "formalization_status")
        err(file, "expectation", "documents formalization status #{want.inspect}, record has #{got.inspect}") if want && want != got
      when "candidate_objections"
        saw_any = true
        if want == "empty" && !objections.empty?
          err(file, "expectation", "documents candidate_objections empty, record has #{objections.length}")
        end
      end
    end
  end

  warn_at(file, "expectation", "no machine-checkable expectations found in the " \
                               "'## Expected' table") unless saw_any
end

# --- driver ----------------------------------------------------------------

files = if ARGV.empty?
          Dir["examples/*.md"].sort + Dir["tests/*.md"].sort + ["README.md"]
        else
          ARGV
        end

unless files.all? { |f| File.file?(f) }
  warn "usage: check-consistency.rb [file ...]"
  exit 2
end

records = []
files.each do |file|
  text = File.read(file)
  text.scan(/^```yaml\n(.*?)^```/m) do |match|
    block = match[0]
    begin
      rec = YAML.safe_load(block, aliases: true)
    rescue StandardError => e
      err(file, "parse", "yaml block did not parse: #{e.class}: #{e.message}")
      next
    end
    next unless rec.is_a?(Hash) && rec.key?("overall_result")

    records << [file, rec]
    # Checked for any file that documents expectations, wherever it lives, so
    # the mutation test can exercise this layer on a temporary copy.
    if text.match?(/^##\s+Expected\s*$/)
      check_expectations(file, text, rec, strict: File.dirname(file) == "tests")
    end
  end
end

records.each { |file, rec| check_record(file, rec) }

def summary(file, rec)
  ids = list(rec["candidate_objections"]).map { |o| o["id"] }.compact
  ids = ["no objections"] if ids.empty?
  "#{ids.join(',')} -> #{rec.dig('overall_result', 'result')}"
end

puts "epistemic-redteam :: consistency check"
puts "files scanned : #{files.length}"
puts "records found : #{records.length}"
puts

records.each { |file, rec| puts format("  %-32s %s", File.basename(file), summary(file, rec)) }
puts

if WARNINGS.any?
  puts "WARNINGS (#{WARNINGS.length}) - heuristics, read these places:"
  WARNINGS.each { |f, r, m| puts format("  %-32s %-10s %s", File.basename(f), r, m) }
  puts
end

if ERRORS.any?
  puts "ERRORS (#{ERRORS.length}) - rule violations:"
  ERRORS.each { |f, r, m| puts format("  %-32s %-10s %s", File.basename(f), r, m) }
  puts
  puts "FAILED: #{ERRORS.length} error(s), #{WARNINGS.length} warning(s)."
  exit 1
end

puts "PASSED: #{records.length} record(s) consistent with schema.md, " \
     "#{WARNINGS.length} warning(s)."
puts
puts "This checker verifies internal coherence and expectation agreement, not"
puts "correctness. A record can pass every rule here and still be a wrong audit:"
puts "nothing above can tell you whether an objection should have been supported,"
puts "or whether the evidence boundary matches what was actually supplied. These"
puts "are hand-built examples, not a sample, so they do not estimate precision,"
puts "recall, or calibration."
exit 0