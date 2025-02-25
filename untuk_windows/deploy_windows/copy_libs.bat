@echo on
setlocal enabledelayedexpansion

set DEST_DIR=libs

:: Buat folder libs jika belum ada
if not exist "%DEST_DIR%" mkdir "%DEST_DIR%"

:: Loop setiap baris dalam copy_libs.txt dan salin ke libs/
for /f "delims=" %%F in (copy_libs.txt) do (
    echo Copying %%F to %DEST_DIR%...
    copy /Y "%%F" "%DEST_DIR%"
)

echo All files copied successfully!
pause
