#!/usr/bin/env bash
set -euo pipefail

ICON_DIR="assets/icons"

if ! command -v flutter >/dev/null 2>&1; then
  echo "flutter not found on PATH"; exit 1
fi

shopt -s nullglob
SVGS=("$ICON_DIR"/*.svg)
if [ ${#SVGS[@]} -eq 0 ]; then
  echo "No SVGs found in $ICON_DIR"; exit 0
fi

echo "Generating .svg.vec for ${#SVGS[@]} icons..."
for f in "${SVGS[@]}"; do
  out="${f}.vec"
  echo "  - $f -> $out"
  flutter pub run vector_graphics_compiler --input "$f" --output "$out"
done
echo "Done."

