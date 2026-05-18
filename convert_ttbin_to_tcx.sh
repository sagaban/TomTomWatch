#!/bin/bash
# Convert every .ttbin under a source dir into a .tcx (Strava-friendly).
# Uses ttbincnv from the ttwatch suite in pipe mode, because its
# in-place file-output mode is broken in the Homebrew build.
#
# Usage:
#   ./convert_ttbin_to_tcx.sh                              # defaults
#   ./convert_ttbin_to_tcx.sh <src_dir> <dst_dir>
#
# Defaults:
#   src = target/working/ttbin
#   dst = target/working/tcx
#
# Idempotent: skips files whose .tcx already exists and is non-empty.

set -euo pipefail
cd "$(dirname "$0")"

SRC="${1:-target/working/ttbin}"
DST="${2:-target/working/tcx}"

if ! command -v ttbincnv >/dev/null; then
    echo "ttbincnv not found. Install via the ttwatch suite (https://github.com/ryanbinns/ttwatch)." >&2
    exit 1
fi

if [ ! -d "$SRC" ]; then
    echo "Source directory not found: $SRC" >&2
    exit 1
fi

total=0
converted=0
skipped=0
failed=0

while IFS= read -r -d '' ttbin; do
    total=$((total + 1))
    rel="${ttbin#$SRC/}"
    tcx="$DST/${rel%.ttbin}.tcx"

    if [ -s "$tcx" ]; then
        skipped=$((skipped + 1))
        continue
    fi

    mkdir -p "$(dirname "$tcx")"

    if ttbincnv -t -E < "$ttbin" > "$tcx" 2>/dev/null && [ -s "$tcx" ]; then
        converted=$((converted + 1))
        printf "  [%4d] %s\n" "$converted" "$rel"
    else
        /bin/rm -f "$tcx"
        failed=$((failed + 1))
        echo "  FAIL: $rel" >&2
    fi
done < <(find "$SRC" -type f -name "*.ttbin" -print0)

echo
echo "Total found:  $total"
echo "Converted:    $converted"
echo "Skipped:      $skipped (already converted)"
echo "Failed:       $failed"
echo
echo "Output: $DST"
