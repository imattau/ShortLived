#!/usr/bin/env bash
set -euo pipefail
if grep -R "Placeholder(" lib >/dev/null 2>&1; then
  echo "Error: Found Placeholder() in lib/. Remove debug placeholders before commit."
  exit 1
fi
echo "OK: no Placeholder widgets found."
