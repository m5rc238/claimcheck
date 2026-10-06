#!/usr/bin/env bash
#
# Test entry point.
#
# Runs two suites:
#   1. check-consistency.rb  - schema coherence and expectation agreement for
#                              every critique record in examples/ and tests/
#   2. mutation-test.rb      - injects one violation per documented rule and
#                              confirms the checker reports it
#
# No network, no dependencies. Ruby standard library only.
#
# Exit: 0 all suites pass, 1 a suite failed, 2 setup error.
#
# WHAT A PASS DOES NOT MEAN
#   That the protocol is reliable, or that the judgments in these records are
#   correct. Suite 1 checks internal consistency; suite 2 checks that the
#   consistency checks are load-bearing. Neither can tell you whether an
#   objection should have been supported. These are hand-built examples, not a
#   sample of anything, so no rate, precision, or recall may be inferred from
#   them.

set -uo pipefail

cd "$(dirname "$0")/.." || exit 2

if ! command -v ruby >/dev/null 2>&1; then
  echo "setup error: ruby not found on PATH (the checker uses only the standard library)"
  exit 2
fi

status=0

echo "=============================================================="
echo " 1/2  schema coherence and expectation agreement"
echo "=============================================================="
ruby tests/check-consistency.rb || status=1

echo
echo "=============================================================="
echo " 2/2  mutation test (are the rules load-bearing?)"
echo "=============================================================="
ruby tests/mutation-test.rb || status=1

echo
if [ "$status" -eq 0 ]; then
  echo "ALL SUITES PASSED"
else
  echo "SUITE FAILURE"
fi
echo
echo "Reminder: a passing suite means the records are internally coherent and"
echo "the checks are load-bearing. It says nothing about whether any judgment"
echo "in them was right, and nothing about precision, recall, or calibration."
echo "No ground truth was used anywhere in this repository."
exit "$status"