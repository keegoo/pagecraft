#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

INPUT="${1:?Usage: build-epub.sh <input.md>}"
OUTPUT_DIR="$ROOT_DIR/epubs"
mkdir -p "$OUTPUT_DIR"
OUTPUT="$OUTPUT_DIR/$(basename "${INPUT%.*}").epub"

ARGS=(
  --css="$ROOT_DIR/styles/epub.css"
  --toc
  --toc-depth=2
)

# 如果书目录里有 metadata.yaml，带入 epub 元数据（书名/作者/版权等）
METADATA="$(dirname "$INPUT")/metadata.yaml"
if [[ -f "$METADATA" ]]; then
  ARGS+=(--metadata-file="$METADATA")
fi

pandoc "$INPUT" "${ARGS[@]}" -o "$OUTPUT"

echo "Generated: $OUTPUT"
