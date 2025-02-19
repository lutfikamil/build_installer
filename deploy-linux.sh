#!/bin/bash

set -e  # Hentikan eksekusi jika ada kesalahan
set -x  # Mode debug untuk melihat perintah yang dijalankan

# Pastikan skrip ini dijalankan dari dalam build-installer
BASE_DIR=$(pwd)

# Path bin
BIN_DIR="$BASE_DIR/../bin"
INSTALL_DIR="$BASE_DIR/install"

# Pastikan folder bin ada
if [ ! -d "$BIN_DIR" ]; then
    echo "❌ Folder bin tidak ditemukan! Harap jalankan dari build-installer yang benar."
    exit 1
fi

# Copy install.sh ke bin
cp install.sh "$BIN_DIR/"
chmod +x "$BIN_DIR/install.sh"

cd "$BIN_DIR"

# Cari file eksekusi di folder bin
EXECUTABLE=$(find . -maxdepth 1 -type f -executable ! -name "*.sh" | head -n 1)

if [ -z "$EXECUTABLE" ]; then
    echo "❌ Tidak ada file eksekusi yang ditemukan di $(pwd)!"
    exit 1
fi

echo "🔍 Ditemukan eksekutabel: $EXECUTABLE"

LIBS_DIR="$BIN_DIR/libs"
PLUGINS_DIR="$BIN_DIR/plugins"

# Pastikan path Qt plugin sesuai dengan OS
if [ -f "/etc/debian_version" ]; then
    QT_PLUGIN_PATH="/usr/lib/x86_64-linux-gnu/qt5/plugins"
elif [ -f "/etc/arch-release" ]; then
    QT_PLUGIN_PATH="/usr/lib/qt/plugins"
else
    echo "❌ OS tidak dikenali! Pastikan Qt plugin path benar."
    exit 1
fi

mkdir -p "$LIBS_DIR" "$PLUGINS_DIR"

echo "📦 Mengumpulkan library yang dibutuhkan oleh $EXECUTABLE..."

ldd "$EXECUTABLE" | grep "=> /" | awk '{print $3}' | xargs -I '{}' cp --update=none -v '{}' "$LIBS_DIR/" || true
echo "📦 Mengumpulkan libQt5..."
ldd "$EXECUTABLE" | grep "libQt5" | awk '{print $3}' | xargs -I '{}' cp --update=none -v '{}' "$LIBS_DIR/" || true

echo "✅ Semua library telah dikumpulkan di $LIBS_DIR"
echo "🔍 Menganalisis plugin yang dibutuhkan..."

if ! command -v strace &> /dev/null; then
    echo "⚠️ strace belum terinstal, menginstal sekarang..."
    if [ -f "/etc/debian_version" ]; then
        sudo apt update && sudo apt install strace -y
    elif [ -f "/etc/arch-release" ]; then
        sudo pacman -S strace --noconfirm
    fi
fi

strace -f -e trace=open,openat ./$EXECUTABLE 2>&1 | grep "plugins" | grep -oE '/[^ ]+' | sort -u > plugins_list.txt

sed -i 's/",$//g' plugins_list.txt

echo "📂 Mengumpulkan plugin yang ditemukan..."

while read -r file; do
    if [ -f "$file" ]; then
        REL_PATH="${file#$QT_PLUGIN_PATH/}"
        mkdir -p "$PLUGINS_DIR/$(dirname "$REL_PATH")"
        cp -v "$file" "$PLUGINS_DIR/$REL_PATH"
    fi
done < plugins_list.txt

rm plugins_list.txt

echo "✅ Semua plugin telah dikumpulkan di $PLUGINS_DIR"

echo "🎉 Proses pengumpulan selesai, sekarang membuat installer..."

# Pindah ke build-installer
cd "$BASE_DIR"

mkdir -p "$INSTALL_DIR"

tar -czf "$INSTALL_DIR/bin.tar.gz" -C "$BIN_DIR" .

cp wrapper.sh "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/wrapper.sh"

# Pastikan makeself terinstal
if ! command -v makeself &> /dev/null; then
    echo "⚠️ makeself belum terinstal, menginstal sekarang..."
    if [ -f "/etc/debian_version" ]; then
        sudo apt update && sudo apt install makeself -y
    elif [ -f "/etc/arch-release" ]; then
        sudo pacman -S makeself --noconfirm
    else
        echo "❌ Tidak dapat menginstal makeself secara otomatis. Silakan instal secara manual!"
        exit 1
    fi
fi

# Buat installer
makeself "$INSTALL_DIR" "sultan-lm-installer.run" "Sultan Installer" ./wrapper.sh 

echo "✅ Installer berhasil dibuat: sultan-lm-installer.run"

