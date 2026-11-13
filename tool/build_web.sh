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

# Packages are resolved beforehand (`dart pub get`, as CI does), so the
# build itself never needs the network.
flags=(--release --wasm --no-web-resources-cdn --no-wasm-dry-run --no-pub)

(cd "$root/apps/glowhaus" &&
  flutter build web "${flags[@]}" --base-href "$base" -o "$site")
(cd "$root/widgetbook" &&
  flutter build web "${flags[@]}" --base-href "${base}widgetbook/" \
    -o "$site/widgetbook")

# Debug symbols are never fetched by browsers; keep the deploy lean.
find "$site" -name '*.symbols' -delete

# Every build gets its own directory, b/<id>/, for everything that changes
# between builds: the bootstrap, main.dart.*, the deferred parts, assets and
# the engine. GitHub Pages caches every file for ten minutes under a fixed
# name and cannot be told otherwise, so a returning visitor could get the
# old main.dart.* (or, worse, an old .mjs with a new .wasm). Now only three
# files keep their names: index.html, a root flutter_bootstrap.js that asks
# build.json (with `cache: 'no-store'`) which build is current, and
# build.json itself. A stale index.html or loader still finds the newest
# build; the files of a build never change under their URL.
version_site() {
  local dir="$1" id
  id="$(cd "$dir" && find . -type f -print0 | LC_ALL=C sort -z |
    xargs -0 shasum -a 256 | shasum -a 256 | cut -c1-12)"
  local build="$dir/b/$id"
  mkdir -p "$build"
  (cd "$dir" && mv main.dart.* flutter_bootstrap.js flutter.js version.json \
    assets canvaskit "b/$id/")

  # The build's own bootstrap loads from its directory (the engine finds
  # assets through a <meta name="assetBase">), and no longer
  # registers Flutter's (deprecated, self-removing) service worker.
  BUILD_ID="$id" perl -0pi -e '
    s/serviceWorkerSettings:\s*\{.*?\}\s*,?//s;
    s/_flutter\.loader\.load\(\{/_flutter.loader.load({\n  config: (function () {\n    var base = new URL("b\/$ENV{BUILD_ID}\/", document.baseURI).href;\n    var meta = document.createElement("meta");\n    meta.name = "assetBase";\n    meta.content = base;\n    document.head.appendChild(meta);\n    return { entrypointBaseUrl: base, canvasKitBaseUrl: base + "canvaskit\/" };\n  })(),/;
  ' "$build/flutter_bootstrap.js"
  grep -q "config: (function" "$build/flutter_bootstrap.js" ||
    { echo "could not patch $build/flutter_bootstrap.js" >&2; exit 1; }

  printf '{"id":"%s"}\n' "$id" > "$dir/build.json"
  cat > "$dir/flutter_bootstrap.js" <<JS
// Starts the current build. index.html and this file may come from the
// browser's cache; build.json never does, so a returning visitor always
// gets the latest build. The id below is only for when build.json cannot
// be read.
(function () {
  function start(id) {
    var script = document.createElement('script');
    script.src = 'b/' + id + '/flutter_bootstrap.js';
    script.async = true;
    document.body.appendChild(script);
  }
  fetch('build.json', { cache: 'no-store' })
    .then(function (r) { return r.ok ? r.json() : Promise.reject(r.status); })
    .then(function (b) { start(b.id); })
    .catch(function () { start('$id'); });
})();
JS
  BUILD_DIR="$build"
}

version_site "$site/widgetbook"
version_site "$site"

"$root/tool/web_size_report.sh" "$BUILD_DIR"
