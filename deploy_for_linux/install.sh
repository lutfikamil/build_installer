#!/bin/bash

set -e  # Hentikan eksekusi jika ada kesalahan

EXECUTABLE="Sultan"

if [ ! -x "$EXECUTABLE" ]; then
    echo "❌ Tidak ada file eksekusi yang ditemukan dalam $(pwd)"
    exit 1
fi

EXECUTABLE_NAME=$(basename "$EXECUTABLE")
INSTALL_FOLDER_NAME=$(echo "$EXECUTABLE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"-lm"

TMP_DIR="/tmp/${INSTALL_FOLDER_NAME}-v1.0-installer"
DEFAULT_ROOT_INSTALL_DIR="/opt/$INSTALL_FOLDER_NAME"
DEFAULT_USER_INSTALL_DIR="$HOME/$INSTALL_FOLDER_NAME"

echo "📦 Anda akan menginstal $EXECUTABLE_NAME. Semoga sukses! 🚀"

# Menentukan lokasi instalasi
if [ "$(id -u)" -eq 0 ]; then
    INSTALL_DIR="$DEFAULT_ROOT_INSTALL_DIR"
    SUDO="sudo"
else
    INSTALL_DIR="$DEFAULT_USER_INSTALL_DIR"
    SUDO=""
    echo "🔹 Apakah Anda ingin mencoba menginstal di '/opt/' dengan sudo? (y/N)"
    read -r ROOT_CHOICE
    if [[ "$ROOT_CHOICE" =~ ^[Yy]$ ]]; then
        echo "🔑 Memerlukan hak akses root untuk melanjutkan..."
        if sudo -v; then
            INSTALL_DIR="$DEFAULT_ROOT_INSTALL_DIR"
            SUDO="sudo"
        else
            echo "❌ Gagal mendapatkan akses root. Instalasi akan dilakukan di: $DEFAULT_USER_INSTALL_DIR"
        fi
    fi
fi

echo "📂 Instalasi akan dilakukan di: $INSTALL_DIR"
$SUDO mkdir -p "$INSTALL_DIR"
echo "✅ Direktori instalasi siap."

# Pindahkan file ke direktori instalasi
echo "📦 Menyalin file aplikasi ke $INSTALL_DIR"
$SUDO mv "$TMP_DIR/bin"/* "$INSTALL_DIR/"

# Memastikan file utama bisa dieksekusi
$SUDO chmod +x "$INSTALL_DIR/$EXECUTABLE_NAME"

# Mengecek apakah MySQL atau MariaDB sudah terinstal
echo "🛠️ Mengecek MySQL/MariaDB..."
if command -v mariadb &> /dev/null || command -v mysql &> /dev/null; then
    echo "✅ MySQL atau MariaDB sudah terinstal."
else
    echo "❓ MariaDB tidak ditemukan, Apakah Anda ingin menginstalnya? (y/n)"
    read -r INSTALL_MARIADB
    if [[ "$INSTALL_MARIADB" =~ ^[Yy]$ ]]; then
        if [ -f "/etc/debian_version" ]; then
            sudo apt update && sudo apt install -y mariadb-server
            sudo systemctl enable mariadb
            sudo systemctl start mariadb
        elif [ -f "/etc/arch-release" ]; then
            sudo pacman -S --noconfirm mariadb
            sudo systemctl enable mariadb
            sudo systemctl start mariadb
        else
            echo "❌ Distro tidak dikenali! Instal MariaDB secara manual."
        fi
    else
        echo "🔹 Database akan menggunakan SQLite"
    fi
fi

# Menambahkan launcher
DESKTOP_FILE="[Desktop Entry]
Name=$EXECUTABLE_NAME
Exec=$INSTALL_DIR/$EXECUTABLE_NAME
Icon=$INSTALL_DIR/icon.png
Type=Application
Categories=Office;
Terminal=false"

if [ "$INSTALL_DIR" = "$DEFAULT_ROOT_INSTALL_DIR" ]; then
    echo "Menambahkan launcher ke menu aplikasi..."
    echo "$DESKTOP_FILE" | sudo tee /usr/share/applications/${EXECUTABLE_NAME}.desktop > /dev/null
    sudo chmod 755 /usr/share/applications/${EXECUTABLE_NAME}.desktop
    sudo update-desktop-database /usr/share/applications
else
    echo "Menambahkan launcher ke menu aplikasi user..."
    mkdir -p "$HOME/.local/share/applications"
    echo "$DESKTOP_FILE" > "$HOME/.local/share/applications/${EXECUTABLE_NAME}.desktop"
    chmod +x "$HOME/.local/share/applications/${EXECUTABLE_NAME}.desktop"
    update-desktop-database "$HOME/.local/share/applications"
fi

echo "🧹 Membersihkan file sementara..."
rm -rf "$TMP_DIR"
trap 'rm -- "$0"' EXIT
echo "📂 Skrip ini akan menghapus dirinya sendiri setelah selesai..."
sleep 2
echo "🏁️ Instalasi selesai! Jalankan aplikasi dengan: $INSTALL_DIR/$EXECUTABLE_NAME"
