#!/bin/bash

set -e
#set -x

BASE_DIR=$(pwd)
BIN_DIR="$BASE_DIR/bin"
INSTALL_DIR="$BASE_DIR/install"

LIBS_DIR="$BIN_DIR"
PLUGINS_DIR="$BIN_DIR"

echo "📂 Path bin: $BIN_DIR"
echo "📂 Path install: $INSTALL_DIR"

cp install.sh icon.png "$BIN_DIR/"
chmod +x "$BIN_DIR/install.sh"

cd "$BIN_DIR"

read -p "Masukkan nama executable (default: Sultan): " EXECUTABLE
EXECUTABLE=${EXECUTABLE:-"Sultan"}

if [ ! -x "$EXECUTABLE" ]; then
    echo "❌ Tidak ada file eksekusi yang ditemukan!"
    exit 1
fi

if [ -f "/etc/debian_version" ]; then
    QT_PLUGIN_PATH="/usr/lib/x86_64-linux-gnu/qt5/plugins"
elif [ -f "/etc/arch-release" ]; then
    QT_PLUGIN_PATH="/usr/lib/qt/plugins"
else
    echo "❌ OS tidak dikenali! Pastikan Qt plugin path benar."
    exit 1
fi

echo "📦 Mengumpulkan library dan libQt5 yang dibutuhkan..."
ldd "$EXECUTABLE" | awk '{print $3}' | grep -v '^(' | xargs -I '{}' cp --update=none -v '{}' "$LIBS_DIR/" || true
ldd "$EXECUTABLE" | grep "libQt5" | awk '{print $3}' | xargs -I '{}' cp --update=none -v '{}' "$LIBS_DIR/" || true

if ! command -v strace &> /dev/null; then
    echo "⚠️ strace belum terinstal, menginstal sekarang..."
    if [ -f "/etc/debian_version" ]; then
        sudo apt update && sudo apt install strace -y
    elif [ -f "/etc/arch-release" ]; then
        sudo pacman -S strace --noconfirm
    fi
fi

echo "Tekan 'ENTER' Tahap mencari Plugins akan membuka aplikasi, Silahkan Buka fitur2 aplikasi untuk memastikan plugins terpanggil, Kemudian tutup aplikasi untuk melanjutkan pengumpulan plugins..."
read -r
strace -f -e trace=open,openat ./$EXECUTABLE 2>&1 | grep -oE '/.*plugins/[^ "]+' | sort -u > plugins_list.txt

while read -r file; do
    if [ -d "$file" ]; then
        REL_PATH="${file#$QT_PLUGIN_PATH/}"
        mkdir -p "$PLUGINS_DIR/$REL_PATH"
    elif [ -f "$file" ]; then
        REL_PATH="${file#$QT_PLUGIN_PATH/}"
        mkdir -p "$PLUGINS_DIR/$(dirname "$REL_PATH")"
        cp -v "$file" "$PLUGINS_DIR/$REL_PATH"
    else
        echo "⚠️ Tidak ditemukan: $file"
    fi
done < plugins_list.txt

rm plugins_list.txt

echo "✅ Semua plugin telah dikumpulkan di $PLUGINS_DIR"
echo "🎉 Membuat installer..."

cd $BASE_DIR
mkdir -p "$INSTALL_DIR"
tar -czf "$INSTALL_DIR/bin.tar.gz" bin/
cp wrapper.sh "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/wrapper.sh"

if ! command -v makeself &> /dev/null; then
    echo "⚠️ makeself belum terinstal, menginstal sekarang..."
    if [ -f "/etc/debian_version" ]; then
        sudo apt update && sudo apt install makeself -y
    elif [ -f "/etc/arch-release" ]; then
        sudo pacman -S makeself --noconfirm
    else
        echo "❌ Tidak dapat menginstal makeself secara otomatis. Silakan install secara manual!"
        exit 1
    fi
fi

makeself "$INSTALL_DIR" "sultan-lm-installer.run" "Sultan Installer" "./wrapper.sh"
echo "✅ Installer berhasil dibuat: linux_sultan-lm-installer.run"
