#!/bin/bash
set -euo pipefail

# ============================================
# Dispatch QA Report Generator
# ============================================
# Usage: ./scripts/generate-report.sh <date> <screenshots-dir> [findings.md]
#
# Arguments:
#   date            - Report date (YYYY-MM-DD)
#   screenshots-dir - Directory containing screenshots (*.png, *.jpg)
#   findings.md     - Optional markdown file with test findings
#
# Example:
#   ./scripts/generate-report.sh 2026-02-17 /tmp/screenshots findings.md
#
# Output:
#   - Copies screenshots to assets/<date>/
#   - Generates reports/<date>-sim-test.html from template
#   - Git adds and commits

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# ── Args ─────────────────────────────────────
DATE="${1:-}"
SCREENSHOTS_DIR="${2:-}"
FINDINGS_FILE="${3:-}"

if [ -z "$DATE" ] || [ -z "$SCREENSHOTS_DIR" ]; then
  echo "Usage: $0 <date> <screenshots-dir> [findings.md]"
  echo ""
  echo "Example: $0 2026-02-17 /tmp/screenshots notes.md"
  exit 1
fi

if [ ! -d "$SCREENSHOTS_DIR" ]; then
  echo "Error: Screenshots directory '$SCREENSHOTS_DIR' not found"
  exit 1
fi

# ── Config ───────────────────────────────────
REPORT_FILE="$REPO_DIR/reports/${DATE}-sim-test.html"
ASSETS_DIR="$REPO_DIR/assets/${DATE}"
TEMPLATE="$REPO_DIR/templates/report.html"

if [ ! -f "$TEMPLATE" ]; then
  echo "Error: Template not found at $TEMPLATE"
  exit 1
fi

if [ -f "$REPORT_FILE" ]; then
  echo "Warning: Report $REPORT_FILE already exists. Overwriting."
fi

# ── Copy Screenshots ────────────────────────
echo "📸 Copying screenshots to assets/${DATE}/..."
mkdir -p "$ASSETS_DIR"

SCREENSHOT_COUNT=0
for img in "$SCREENSHOTS_DIR"/*.{png,jpg,jpeg,PNG,JPG,JPEG} 2>/dev/null; do
  [ -f "$img" ] || continue
  cp "$img" "$ASSETS_DIR/"
  SCREENSHOT_COUNT=$((SCREENSHOT_COUNT + 1))
  echo "   → $(basename "$img")"
done

echo "   Copied $SCREENSHOT_COUNT screenshots."

# ── Generate Gallery HTML ────────────────────
GALLERY_HTML=""
for img in "$ASSETS_DIR"/*.{png,jpg,jpeg,PNG,JPG,JPEG} 2>/dev/null; do
  [ -f "$img" ] || continue
  BASENAME=$(basename "$img")
  NAME="${BASENAME%.*}"
  # Convert underscores/hyphens to spaces for caption
  CAPTION=$(echo "$NAME" | sed 's/[_-]/ /g' | sed 's/\b\(.\)/\u\1/g')
  GALLERY_HTML="${GALLERY_HTML}
      <figure class=\"gallery__item\">
        <img src=\"../assets/${DATE}/${BASENAME}\" alt=\"${CAPTION}\" loading=\"lazy\">
        <figcaption>${CAPTION}</figcaption>
      </figure>"
done

# ── Generate Report ──────────────────────────
echo "📝 Generating report..."

# Format the display date
DISPLAY_DATE=$(date -j -f "%Y-%m-%d" "$DATE" "+%b %d, %Y" 2>/dev/null || echo "$DATE")
ISO_DATE="${DATE}T12:00:00-05:00"

# Start from template
cp "$TEMPLATE" "$REPORT_FILE"

# Replace placeholders
sed -i '' "s|{{APP_NAME}}|DispatchApp|g" "$REPORT_FILE"
sed -i '' "s|{{TEST_TYPE}}|Simulator Test|g" "$REPORT_FILE"
sed -i '' "s|{{DATE}}|${DATE}|g" "$REPORT_FILE"
sed -i '' "s|{{ISO_DATE}}|${ISO_DATE}|g" "$REPORT_FILE"
sed -i '' "s|{{DISPLAY_DATE}}|${DISPLAY_DATE}|g" "$REPORT_FILE"
sed -i '' "s|{{DEVICE}}|iPhone 16 Pro Simulator (iOS 18.2)|g" "$REPORT_FILE"
sed -i '' "s|{{BRANCH}}|main|g" "$REPORT_FILE"
sed -i '' "s|{{COMMIT}}|HEAD|g" "$REPORT_FILE"
sed -i '' "s|{{TESTER}}|Mentat (Automated)|g" "$REPORT_FILE"
sed -i '' "s|{{STATUS}}|In Progress|g" "$REPORT_FILE"
sed -i '' "s|{{TOTAL}}|10|g" "$REPORT_FILE"
sed -i '' "s|{{PASSED}}|0|g" "$REPORT_FILE"
sed -i '' "s|{{FAILED}}|0|g" "$REPORT_FILE"
sed -i '' "s|{{SKIPPED}}|0|g" "$REPORT_FILE"
sed -i '' "s|{{PENDING}}|10|g" "$REPORT_FILE"

# Insert gallery if we have screenshots
if [ -n "$GALLERY_HTML" ]; then
  # Replace the "No screenshots" placeholder with actual gallery
  # Using a temp file to handle multi-line replacement
  python3 -c "
import sys
with open('$REPORT_FILE', 'r') as f:
    content = f.read()
content = content.replace('<p class=\"text-dim\">No screenshots captured yet.</p>', '''$GALLERY_HTML''')
with open('$REPORT_FILE', 'w') as f:
    f.write(content)
"
fi

# ── Process Findings (if provided) ──────────
if [ -n "$FINDINGS_FILE" ] && [ -f "$FINDINGS_FILE" ]; then
  echo "📋 Processing findings from $FINDINGS_FILE..."
  # Basic markdown to HTML conversion for findings
  # This is intentionally simple — for complex reports, edit the HTML directly
  FINDINGS_HTML=$(python3 -c "
import re, html, sys

with open('$FINDINGS_FILE', 'r') as f:
    text = f.read()

# Escape HTML
text = html.escape(text)

# Convert markdown-ish formatting
text = re.sub(r'\*\*(.*?)\*\*', r'<strong>\1</strong>', text)
text = re.sub(r'^# (.*?)$', r'<h3>\1</h3>', text, flags=re.MULTILINE)
text = re.sub(r'^## (.*?)$', r'<h4>\1</h4>', text, flags=re.MULTILINE)
text = re.sub(r'^- (.*?)$', r'<li>\1</li>', text, flags=re.MULTILINE)
text = re.sub(r'(<li>.*?</li>(\n|$))+', lambda m: '<ul>' + m.group(0) + '</ul>', text)
text = re.sub(r'\n\n', '</p><p>', text)
text = '<p>' + text + '</p>'

print(text)
")

  # Insert findings into the bug section
  python3 -c "
import sys
with open('$REPORT_FILE', 'r') as f:
    content = f.read()
content = content.replace('<p class=\"text-dim\">No bugs found yet.</p>', '''$FINDINGS_HTML''')
with open('$REPORT_FILE', 'w') as f:
    f.write(content)
"
fi

echo ""
echo "✅ Report generated: $REPORT_FILE"
echo "📸 Screenshots: $ASSETS_DIR/ ($SCREENSHOT_COUNT files)"
echo ""

# ── Git ──────────────────────────────────────
cd "$REPO_DIR"
git add "reports/${DATE}-sim-test.html" "assets/${DATE}/"
echo "📦 Staged for commit. Run:"
echo "   git commit -m 'Add QA report for ${DATE}'"
echo "   git push"
