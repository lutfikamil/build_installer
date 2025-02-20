#!/bin/bash

set -e  # Hentikan eksekusi jika ada kesalahan

# Cari executable di dalam bin/
EXECUTABLE=$(find bin/ -maxdepth 1 -type f -executable ! -name "*.sh" | head -n 1)

if [ -z "$EXECUTABLE" ]; then
    echo "❌ Tidak ada file eksekusi yang ditemukan dalam bin/"
    exit 1
fi

EXECUTABLE_NAME=$(basename "$EXECUTABLE")
INSTALL_FOLDER_NAME=$(echo "$EXECUTABLE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"-v1.0"

TMP_DIR="/tmp/${INSTALL_FOLDER_NAME}-installer"
DEFAULT_ROOT_INSTALL_DIR="/opt/$INSTALL_FOLDER_NAME"
DEFAULT_USER_INSTALL_DIR="$HOME/$INSTALL_FOLDER_NAME"

echo "📦 Anda akan menginstal $EXECUTABLE_NAME. Semoga sukses! 🚀"

# Menentukan lokasi instalasi
if [ "$(id -u)" -eq 0 ]; then
    echo "🛠️ Anda memiliki akses root."
    echo "🔹 Apakah Anda ingin menginstal ke '$DEFAULT_ROOT_INSTALL_DIR'? (Y/n)"
    read -r INSTALL_CHOICE
    if [[ "$INSTALL_CHOICE" =~ ^[Nn]$ ]]; then
        INSTALL_DIR="$DEFAULT_USER_INSTALL_DIR"
    else
        INSTALL_DIR="$DEFAULT_ROOT_INSTALL_DIR"
    fi
else
    echo "⚠️ Anda TIDAK memiliki akses root."
    echo "🔹 Apakah Anda ingin mencoba menginstal ke '$DEFAULT_ROOT_INSTALL_DIR' dengan sudo? (y/N)"
    read -r ROOT_CHOICE
    if [[ "$ROOT_CHOICE" =~ ^[Yy]$ ]]; then
        echo "🔑 Memerlukan hak akses root untuk melanjutkan..."
        if sudo -v; then
            INSTALL_DIR="$DEFAULT_ROOT_INSTALL_DIR"
            SUDO="sudo"
        else
            echo "❌ Gagal mendapatkan akses root. Instalasi akan dilakukan di: $DEFAULT_USER_INSTALL_DIR"
            INSTALL_DIR="$DEFAULT_USER_INSTALL_DIR"
            SUDO=""
        fi
    else
        INSTALL_DIR="$DEFAULT_USER_INSTALL_DIR"
        SUDO=""
    fi
fi

echo "📂 Instalasi akan dilakukan di: $INSTALL_DIR"
# Membuat folder instalasi
$SUDO mkdir -p "$INSTALL_DIR/bin"
echo "✅ Direktori instalasi siap."

# Pindahkan semua file dari paket 'bin/' ke direktori instalasi
echo "📦 Menyalin file aplikasi ke $INSTALL_DIR/bin/..."
$SUDO cp -r bin "$INSTALL_DIR/"

# Memastikan file utama bisa dieksekusi
$SUDO chmod +x "$INSTALL_DIR/bin/$EXECUTABLE_NAME"

# Mengecek apakah MySQL atau MariaDB sudah terinstal
echo "🛠️ Mengecek MySQL/MariaDB..."
if command -v mysql &> /dev/null; then
    echo "✅ MySQL atau MariaDB sudah terinstal."
else
    echo "⚠️ MariaDB atau MySQL tidak ditemukan."
    echo "❓ Apakah Anda ingin menginstal MariaDB? (y/n)"
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
        echo "🔹 Database akan ditentukan oleh aplikasi $EXECUTABLE_NAME."
    fi
fi

# Menambahkan launcher
DESKTOP_FILE="[Desktop Entry]
Name=$EXECUTABLE_NAME
Exec=$INSTALL_DIR/bin/$EXECUTABLE_NAME
Icon=$INSTALL_DIR/bin/icon.png
Type=Application
Categories=Utility;
Terminal=false"

if [ "$INSTALL_DIR" = "$DEFAULT_ROOT_INSTALL_DIR" ]; then
    echo "Menambahkan launcher ke menu aplikasi..."
    echo "$DESKTOP_FILE" | sudo tee /usr/share/applications/${EXECUTABLE_NAME}.desktop > /dev/null
    sudo chmod 755 /usr/share/applications/${EXECUTABLE_NAME}.desktop
    sudo update-desktop-database /usr/share/applications
else
    echo "Menambahkan launcher ke Desktop user..."
    echo "$DESKTOP_FILE" > "$HOME/Desktop/${EXECUTABLE_NAME}.desktop"
    chmod +x "$HOME/Desktop/${EXECUTABLE_NAME}.desktop"
    update-desktop-database "$HOME/Desktop"
fi

echo "🧹 Membersihkan file sementara..."
rm -rf "$TMP_DIR"
echo "🏁️ Instalasi selesai! Jalankan aplikasi dengan: $INSTALL_DIR/bin/$EXECUTABLE_NAME"

