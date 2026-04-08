#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PRODUCT_DIR="$REPO_ROOT/src/.github"
FACTORY_DIR="$REPO_ROOT/src/generation"
MIN_LINES=10
ERRORS=0

err() {
  echo "  ERROR: $1"
  ERRORS=$((ERRORS + 1))
}

echo "=== Validating control files (src/.github/) ==="
echo ""

# --- Control file checks ---
while IFS= read -r file; do
  rel="${file#$REPO_ROOT/}"

  # Skip the consumer README and customizations index
  [[ "$file" == "$PRODUCT_DIR/README.md" ]] && continue
  [[ "$file" == "$PRODUCT_DIR/COPILOT_CUSTOMIZATIONS.md" ]] && continue

  echo "  $rel"

  # Frontmatter exists (starts with ---)
  if ! head -1 "$file" | grep -q '^---$'; then
    err "$rel — missing frontmatter (must start with ---)"
  fi

  # Minimum line count
  lines=$(wc -l < "$file")
  if (( lines < MIN_LINES )); then
    err "$rel — only $lines lines (minimum: $MIN_LINES)"
  fi

  # Required frontmatter fields by type
  case "$rel" in
    *instructions/*.instructions.md)
      grep -q '^applyTo:' "$file" || err "$rel — missing required field: applyTo"
      ;;
    *prompts/*.prompt.md)
      grep -q '^description:' "$file" || err "$rel — missing required field: description"
      ;;
    *agents/*.agent.md)
      grep -q '^tools:' "$file" || err "$rel — missing required field: tools"
      ;;
    *skills/*/SKILL.md)
      grep -q '^name:' "$file" || err "$rel — missing required field: name"
      ;;
    *copilot-instructions.md)
      # No type-specific required fields
      ;;
  esac

  # generation-source cross-link resolves
  gen_source=$(grep '^generation-source:' "$file" | sed 's/generation-source: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/' || true)
  if [[ -n "$gen_source" ]]; then
    target="$REPO_ROOT/src/$gen_source"
    if [[ ! -f "$target" ]]; then
      err "$rel — generation-source points to missing file: $gen_source"
    fi
  fi

done < <(find "$PRODUCT_DIR" -name '*.md' -not -name 'README.md' -type f | sort)

echo ""
echo "=== Validating generation files (src/generation/) ==="
echo ""

# --- Generation file checks ---
while IFS= read -r file; do
  rel="${file#$REPO_ROOT/}"
  echo "  $rel"

  # Frontmatter exists
  if ! head -1 "$file" | grep -q '^---$'; then
    err "$rel — missing frontmatter (must start with ---)"
  fi

  # Minimum line count
  lines=$(wc -l < "$file")
  if (( lines < MIN_LINES )); then
    err "$rel — only $lines lines (minimum: $MIN_LINES)"
  fi

  # generates: field exists
  if ! grep -q '^generates:' "$file"; then
    err "$rel — missing required field: generates"
  fi

  # generates: target resolves
  gen_target=$(grep '^generates:' "$file" | sed 's/generates: *"\{0,1\}\([^"]*\)"\{0,1\}/\1/' || true)
  if [[ -n "$gen_target" ]]; then
    target="$PRODUCT_DIR/$gen_target"
    # generates paths start with .github/ — strip it since we're already in .github/
    target="$PRODUCT_DIR/${gen_target#.github/}"
    if [[ ! -f "$target" ]]; then
      err "$rel — generates points to missing file: $gen_target"
    fi
  fi

done < <(find "$FACTORY_DIR" -name '*.md' -type f | sort)

echo ""

# --- File count sanity ---
control_count=$(find "$PRODUCT_DIR" -name '*.md' -not -name 'README.md' -not -name 'COPILOT_CUSTOMIZATIONS.md' -type f | wc -l)
generation_count=$(find "$FACTORY_DIR" -name '*.md' -type f | wc -l)
echo "=== File counts ==="
echo "  Control files:    $control_count"
echo "  Generation files: $generation_count"

if (( control_count != generation_count )); then
  err "Control file count ($control_count) != generation file count ($generation_count) — missing pair?"
fi

echo ""

# --- Result ---
if (( ERRORS > 0 )); then
  echo "FAILED: $ERRORS error(s) found"
  exit 1
else
  echo "PASSED: All checks passed"
fi
