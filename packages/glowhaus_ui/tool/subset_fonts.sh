#!/usr/bin/env bash
# Rebuilds the bundled text fonts from the upstream google/fonts files,
# keeping only the scripts Glowhaus ships (English, Turkish, Persian).
#
# Both fonts are OFL 1.1 without a Reserved Font Name, so subsets may keep
# their names. Glyph outlines, variation axes and OpenType features are
# unchanged; only unused characters are dropped.
#
# Requires fonttools: pip install fonttools
set -euo pipefail

cd "$(dirname "$0")/../assets/fonts"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

upstream="https://raw.githubusercontent.com/google/fonts/main/ofl"
curl -fsSL -o "$work/Manrope.ttf" "$upstream/manrope/Manrope%5Bwght%5D.ttf"
curl -fsSL -o "$work/Vazirmatn.ttf" "$upstream/vazirmatn/Vazirmatn%5Bwght%5D.ttf"

common=(--layout-features='*' --name-IDs='*' --name-languages='*' --notdef-outline)

# Latin: ASCII, Latin-1, Latin Extended-A (Turkish ğ ı İ ş), Romanian
# comma-below letters, a few combining marks, punctuation and symbols.
pyftsubset "$work/Manrope.ttf" --output-file=Manrope-Variable.ttf "${common[@]}" \
  --unicodes="U+0020-007E,U+00A0-017F,U+0218-021B,U+0300-0308,U+030A-030C,U+0326-0328,U+2000-206F,U+20AC,U+20BA,U+2122,U+2190-2193,U+2212,U+2215,U+2248,U+2260,U+2264-2265,U+25CC"

# Persian: Arabic blocks and presentation forms, ZWNJ and direction marks,
# plus ASCII and Latin-1. Other Latin falls back to Manrope.
pyftsubset "$work/Vazirmatn.ttf" --output-file=Vazirmatn-Variable.ttf "${common[@]}" \
  --unicodes="U+0020-007E,U+00A0-00FF,U+0600-06FF,U+0750-077F,U+200B-200F,U+2010-2027,U+2030-205E,U+2066-2069,U+FB50-FDFF,U+FE70-FEFF,U+25CC"

ls -l Manrope-Variable.ttf Vazirmatn-Variable.ttf
