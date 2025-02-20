@echo off
setlocal enabledelayedexpansion

:: Folder tujuan
set LIBS_DIR=bin\libs
set PLUGINS_DIR=bin\plugins

:: Inisialisasi counter
set /a COUNT_LIBS=0
set /a COUNT_PLUGINS=0

:: Pastikan file daftar DLL ada
if not exist plugins_list.txt (
    echo ERROR: File plugins_list.txt tidak ditemukan!
    pause
    exit /b
)

:: Buat folder libs dan plugins jika belum ada
if not exist "%LIBS_DIR%" mkdir "%LIBS_DIR%"
if not exist "%PLUGINS_DIR%" mkdir "%PLUGINS_DIR%"

:: Baca file daftar DLL
for /f "tokens=1,2 delims=	" %%A in (plugins_list.txt) do (
    set DLL_NAME=%%A
    set DLL_PATH=%%B

    :: Pastikan file sumber ada sebelum disalin
    if not exist "!DLL_PATH!" (
        echo WARNING: File tidak ditemukan: !DLL_PATH!
        continue
    )

    :: Jika path mengandung "plugins", masukkan ke folder plugins
    echo !DLL_PATH! | findstr /I "\\plugins\\" >nul
    if not errorlevel 1 (
        echo Salin: "!DLL_PATH!" ke "%PLUGINS_DIR%\"
	set /a COUNT_PLUGINS+=1
        copy "!DLL_PATH!" "%PLUGINS_DIR%\" /Y || echo ERROR: Gagal menyalin "!DLL_PATH!" ke "%PLUGINS_DIR%\"
    ) else (
        echo Salin: "!DLL_PATH!" ke "%LIBS_DIR%\"
	set /a COUNT_LIBS+=1
        copy "!DLL_PATH!" "%LIBS_DIR%\" /Y || echo ERROR: Gagal menyalin "!DLL_PATH!" ke "%LIBS_DIR%\"
    )
)

echo.
echo ==============================
echo   Total file di bin\libs    : %COUNT_LIBS%
echo   Total file di bin\plugins : %COUNT_PLUGINS%
echo ==============================
echo Semua file telah disalin!
pause
