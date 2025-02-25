@echo off
echo =======================================
echo Menjalankan copy_libs.bat...
echo =======================================
call copy_libs.bat

echo =======================================
echo Menjalankan copy_plugins.bat...
echo =======================================
call copy_plugins.bat

echo =======================================
echo Menjalan windeployqt...
echo =======================================
windeployqt ../bin/Sultan.exe

echo =======================================
echo Semua proses selesai!
echo =======================================
pause
