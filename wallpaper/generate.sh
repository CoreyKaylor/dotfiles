#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HTML_FILE="$SCRIPT_DIR/cheatsheet.html"
OUTPUT_FILE="$SCRIPT_DIR/cheatsheet.png"

CHROME=""
for candidate in \
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  "$(command -v chromium || true)" \
  "$(command -v google-chrome-stable || true)"; do
  if [ -n "$candidate" ] && [ -x "$candidate" ]; then CHROME="$candidate"; break; fi
done
if [ -z "$CHROME" ]; then
  echo "Error: no Chrome or Chromium found" >&2; exit 1
fi

echo "Generating wallpaper..."
cd "$SCRIPT_DIR"
"$CHROME" \
  --headless=new --disable-gpu --no-sandbox \
  --screenshot=cheatsheet.png --window-size=3840,2160 \
  --force-device-scale-factor=1 \
  --hide-scrollbars "file://$HTML_FILE"

if [ -f "$OUTPUT_FILE" ]; then
  echo "Generated: $OUTPUT_FILE"
else
  echo "Error: PNG was not generated" >&2; exit 1
fi
