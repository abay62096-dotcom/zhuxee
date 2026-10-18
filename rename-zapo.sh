#!/usr/bin/env bash
# Ganti nama package utama "zapo-js" di seluruh repo (aman, bisa dibatalkan).
#
# Pakai (dari folder root repo):
#   bash rename-zapo.sh nama-package-baru
#
# Yang DIGANTI:
#   - "zapo-js" (package utama + semua import "zapo-js/xxx") -> nama baru
#   - URL repo github.com/vinikjkkj/zapo -> github.com/abay62096-dotcom/zhuxee
#
# Yang SENGAJA TIDAK diubah:
#   - @zapo-js/*      (paket milik pihak lain di npm; kalau diganti npm install gagal)
#   - ZAPO_* / createZapo*  (variabel env & nama fungsi internal)
#   - LICENSE, CHANGELOG*, Cargo.lock (atribusi/riwayat)
#
# Batalkan semua perubahan:  git restore .

set -euo pipefail

NEW="${1:-}"
if [[ ! "$NEW" =~ ^[a-z0-9][a-z0-9-]*$ ]]; then
    echo "Pakai: bash rename-zapo.sh nama-package-baru   (huruf kecil, angka, strip)"
    exit 1
fi
if [[ ! -f package.json || ! -d .git ]]; then
    echo "Jalankan skrip ini dari folder root repo (yang ada package.json dan .git)"
    exit 1
fi
if ! command -v perl >/dev/null; then
    echo "perl tidak ditemukan. Install: sudo apt install perl"
    exit 1
fi

changed=0
while IFS= read -r -d '' f; do
    case "$f" in
        LICENSE | */LICENSE | *CHANGELOG.md | Cargo.lock | */Cargo.lock) continue ;;
    esac
    grep -Iq . "$f" 2>/dev/null || continue # lewati file biner / kosong
    if grep -qE 'zapo-js|vinikjkkj/zapo' "$f"; then
        NEW="$NEW" perl -pi -e '
            s/(?<![@\w-])zapo-js(?![\w-])/$ENV{NEW}/g;
            s{github\.com/vinikjkkj/zapo(?![-\w])}{github.com/abay62096-dotcom/zhuxee}g;
        ' "$f"
        changed=$((changed + 1))
    fi
done < <(git ls-files -z)

echo "Selesai: $changed file diubah. Nama package baru: $NEW"
echo
echo "Sisa penyebutan 'zapo' (sengaja tidak diubah), 15 terbanyak:"
git grep -Iohi '[@A-Za-z0-9_./:-]*zapo[A-Za-z0-9_./-]*' -- . ':!LICENSE' ':!*CHANGELOG.md' ':!*Cargo.lock' |
    sort | uniq -c | sort -rn | head -15
echo
echo "Langkah berikut:  git diff --stat | tail -3   lalu   npm install"
