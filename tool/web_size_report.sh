#!/usr/bin/env bash
# Prints what a first visit to the web demo downloads, per renderer path,
# raw and gzip (GitHub Pages serves gzip). Writes to the GitHub Actions job
# summary when run in CI so size regressions show up in review.
set -euo pipefail

site="${1:?usage: web_size_report.sh <build dir>}"
cd "$site"

kb() { awk -v b="$1" 'BEGIN { printf "%.0f KB", b / 1024 }'; }
raw() { stat -c%s "$1" 2>/dev/null || stat -f%z "$1"; }
gz() { gzip -9c "$1" | wc -c | tr -d ' '; }

fonts=(
  assets/packages/glowhaus_ui/assets/fonts/Manrope-Variable.ttf
  assets/packages/glowhaus_ui/assets/fonts/Lucide.ttf
  assets/fonts/fallback/Roboto-Regular.ttf # the engine's own last resort
)

row() {
  local label="$1"; shift
  local r=0 g=0 f
  for f in "$@"; do
    r=$((r + $(raw "$f")))
    g=$((g + $(gz "$f")))
  done
  printf '| %s | %s | %s |\n' "$label" "$(kb $r)" "$(kb $g)"
}

report=$(
  echo '| First visit downloads | Raw | Gzip |'
  echo '|---|---:|---:|'
  row 'Wasm + skwasm (Chrome, Edge)' \
    main.dart.wasm main.dart.mjs canvaskit/skwasm.wasm canvaskit/skwasm.js "${fonts[@]}"
  row 'Wasm + skwasm_heavy (other WasmGC browsers)' \
    main.dart.wasm main.dart.mjs canvaskit/skwasm_heavy.wasm canvaskit/skwasm_heavy.js "${fonts[@]}"
  row 'JS + CanvasKit (fallback, full)' \
    main.dart.js canvaskit/canvaskit.wasm canvaskit/canvaskit.js "${fonts[@]}"
  row 'JS + CanvasKit (fallback, Chromium)' \
    main.dart.js canvaskit/chromium/canvaskit.wasm canvaskit/chromium/canvaskit.js "${fonts[@]}"
  # dart2js splits deferred imports into part files; dart2wasm in this
  # Flutter version emits one module, so on Wasm they are in the rows above.
  parts=(main.dart.js_*.part.js)
  if [[ -e "${parts[0]}" ]]; then
    row 'JS only: broker settings + MQTT adapter (deferred, on first use)' \
      "${parts[@]}"
  fi
  row 'Vazirmatn (only when Persian is chosen)' \
    assets/packages/glowhaus_ui/assets/fonts/Vazirmatn-Variable.ttf
  row 'NOTICES (only if the license page opens)' assets/NOTICES
)

echo "$report"
if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  { echo '### Web build size'; echo; echo "$report"; } >> "$GITHUB_STEP_SUMMARY"
fi
