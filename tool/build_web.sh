#!/usr/bin/env bash
# Builds the web demo and the Widgetbook catalog into one static site:
#
#   build/site/            the app
#   build/site/widgetbook/ the component catalog
#
# Usage: tool/build_web.sh [base-href]   (default "/"; GitHub Pages uses
#        "/<repo>/")
#
# Renderer: Wasm (skwasm) with automatic fallback to JS + CanvasKit on
# browsers without WasmGC. On Chromium this is the smallest download and the
# fastest start; see docs/architecture.md, "Web build budget".
# CanvasKit/skwasm are served from this site, not Google's CDN.
set -euo pipefail

base="${1:-/}"
root="$(cd "$(dirname "$0")/.." && pwd)"
site="$root/build/site"
rm -rf "$site"

flags=(--release --wasm --no-web-resources-cdn --no-wasm-dry-run)

(cd "$root/apps/glowhaus" &&
  flutter build web "${flags[@]}" --base-href "$base" -o "$site")
(cd "$root/widgetbook" &&
  flutter build web "${flags[@]}" --base-href "${base}widgetbook/" \
    -o "$site/widgetbook")

# Debug symbols are never fetched by browsers; keep the deploy lean.
find "$site" -name '*.symbols' -delete

"$root/tool/web_size_report.sh" "$site"
