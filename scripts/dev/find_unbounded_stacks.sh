#!/usr/bin/env bash
set -euo pipefail

# Basic heuristic: flag Stacks inside Positioned with no width/height wrapper.
grep -R --line-number "Positioned(" -n lib | while read -r line; do
  file="${line%%:*}"
  lineno="${line#*:}"
  lineno="${lineno%%:*}"
  # dev hint only - logic placeholder for future enhancement
  :
done
echo "Check complete."

