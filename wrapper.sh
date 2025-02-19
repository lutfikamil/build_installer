#!/bin/bash
set -e

# Cari executable di dalam bin/
EXECUTABLE=$(find bin/ -maxdepth 1 -type f -executable ! -name "*.sh" | head -n 1)

if [ -z "$EXECUTABLE" ]; then
    echo "❌ Tidak ada file eksekusi yang ditemukan dalam bin/"
    exit 1
fi

EXECUTABLE_NAME=$(basename "$EXECUTABLE")
INSTALL_FOLDER_NAME=$(echo "$EXECUTABLE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"-v1.0"

TMP_DIR="/tmp/${INSTALL_FOLDER_NAME}-installer"

if [ -d "$TMP_DIR" ]; then
    echo "🗑 Membersihkan instalasi sebelumnya..."
    rm -rf "$TMP_DIR"
fi

mkdir -p "$TMP_DIR"
DATA_ARCHIVE="$(dirname "$0")/data.tar.gz"

if [ ! -f "$DATA_ARCHIVE" ]; then
    echo "❌ File data.tar.gz tidak ditemukan!"
    exit 1
fi

tar xf "$DATA_ARCHIVE" -C "$TMP_DIR"

cd "$TMP_DIR" || exit 1
echo "📂 Isi folder sementara:"
ls -l "$TMP_DIR"

# Pastikan install.sh bisa dieksekusi
chmod +x "$TMP_DIR/install.sh"

# Jalankan instalasi
exec "$TMP_DIR/install.sh"
