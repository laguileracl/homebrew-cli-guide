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
perl -CSD -pe 's/[\x{1F300}-\x{1F6FF}\x{1F900}-\x{1F9FF}\x{2600}-\x{26FF}\x{FE0F}]//g' -i $(find "$TMPDIR" -name '*.qmd')
perl -CSD -pe 's/\p{So}//g' -i $(find "$TMPDIR" -name '*.qmd')

# Render PDF in tmpdir
cd "$TMPDIR"
echo "Attempting PDF render with xelatex (more Unicode-friendly)"
if quarto render --to pdf --pdf-engine=xelatex --no-execute; then
  echo "PDF render succeeded with xelatex"
else
  echo "xelatex render failed; sanitizing symbols and retrying with pdflatex"
  perl -CSD -pe 's/\p{S}//g; s/\x{FE0F}//g' -i $(find "$TMPDIR" -name '*.qmd')
  quarto render --to pdf --no-execute
fi

# Move artifacts back if successful (only _book/pdf)
if [ -d "_book" ]; then
  echo "Copying generated _book back to repository"
  rsync -a _book "$REPO_ROOT/"
fi

echo "Sanitized Quarto PDF render completed."
