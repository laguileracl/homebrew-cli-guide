#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(pwd)"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "Creating sanitized copy in $TMPDIR"
# Copy only QMD and supporting metadata to tmpdir
mkdir -p "$TMPDIR"
rsync -a --include='*/' --include='*.qmd' --include='*.yml' --include='*.yaml' --include='*.bib' --exclude='*' "$REPO_ROOT/" "$TMPDIR/"

# Replace common emoji and special unicode that breaks LaTeX
# Add mappings here as needed (hex codepoints)
perl -CSD -pe '\
    s/\x{1F4DD}/[NOTE]/g; # 📝
    s/\x{1F4D6}/[BOOK]/g; # 📖
    s/\x{1F4D1}/[MARK]/g; # 📑
' -i $(find "$TMPDIR" -name '*.qmd')

# Render PDF in tmpdir
cd "$TMPDIR"
quarto render --to pdf --no-execute

# Move artifacts back if successful (only _book/pdf)
if [ -d "_book" ]; then
  echo "Copying generated _book back to repository"
  rsync -a _book "$REPO_ROOT/"
fi

echo "Sanitized Quarto PDF render completed." 
