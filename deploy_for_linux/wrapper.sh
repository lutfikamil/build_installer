#!/bin/bash
set -e

EXECUTABLE="Sultan"

if [ -z "$EXECUTABLE" ]; then
    echo "❌ wrapper.sh Tidak ada file eksekusi yang ditemukan dalam $(pwd)"
    exit 1
fi

EXECUTABLE_NAME=$(basename "$EXECUTABLE")
INSTALL_FOLDER_NAME=$(echo "$EXECUTABLE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"-lm"
TMP_DIR="/tmp/${INSTALL_FOLDER_NAME}-v1.0-installer"
echo "$INSTALL_FOLDER_NAME"
echo "$EXECUTABLE_NAME"
echo "$TMP_DIR"
echo "🗑 Membersihkan instalasi sebelumnya..."
if [ -d "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
fi

mkdir -p "$TMP_DIR"
BIN_ARCHIVE="$(dirname "$0")/bin.tar.gz"

if [ ! -f "$BIN_ARCHIVE" ]; then
    echo "❌ File bin.tar.gz tidak ditemukan!"
    exit 1
fi

tar xf "$BIN_ARCHIVE" -C "$TMP_DIR"

cd "$TMP_DIR/bin" || exit 1
echo "📂 Isi folder sementara:"
ls -l "$TMP_DIR"

chmod +x "$TMP_DIR/bin/install.sh"
exec "$TMP_DIR/bin/install.sh"
