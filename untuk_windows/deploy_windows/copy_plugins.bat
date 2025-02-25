@echo off
setlocal enabledelayedexpansion

set DEST_DIR=plugins

:: Loop setiap baris dalam copy_plugins.txt
for /f "delims=" %%F in (copy_plugins.txt) do (
    set "SRC=%%F"

    :: Lewati jika file/folder tidak ada
    if not exist "%%F" (
        echo Skipping %%F - File or folder not found.
        goto :continue
    )

    :: Jika ada wildcard "*", hanya gunakan nama folder terakhir sebagai REL_PATH
    echo %%F | findstr /R "\\\*$" >nul
    if not errorlevel 1 (
        set "SRC=!SRC:~0,-2!"  :: Hapus "\*" di akhir path

        for %%A in ("!SRC!") do set "REL_PATH=%%~nxA"
        set "TARGET=%DEST_DIR%\!REL_PATH!"

        echo Copying all contents of folder %%F to !TARGET!...
        xcopy /E /I /Y "!SRC!\*" "!TARGET!"
        goto :continue
    )

    :: Jika path adalah folder (tanpa wildcard)
    if exist "%%F\*" (
        for %%A in ("%%F") do set "REL_PATH=%%~nxA"
        set "TARGET=%DEST_DIR%\!REL_PATH!"

        echo Copying folder %%F to !TARGET!...
        xcopy /E /I /Y "%%F" "!TARGET!"
    
    ) else (
        :: Jika path adalah file
        for %%A in ("%%F") do (
            set "FILENAME=%%~nxA"
            set "FILEFOLDER=%%~dpA"
            for %%B in ("!FILEFOLDER:~0,-1!") do set "REL_PATH=%%~nxB"
        )
        
        set "TARGET=%DEST_DIR%\!REL_PATH!\!FILENAME!"

        :: Buat folder tujuan jika belum ada
        for %%P in (!TARGET!) do if not exist "%%~dpP" mkdir "%%~dpP"

        echo Copying file %%F to !TARGET!...
        copy /Y "%%F" "!TARGET!"
    )
)

echo Done!
pause
