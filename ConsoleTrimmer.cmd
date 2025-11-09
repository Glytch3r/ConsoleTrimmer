@echo off
setlocal enabledelayedexpansion

REM Ask for the log file path
set /p LOG_FILE=Enter full path of console.txt: 

REM Strip quotes if present
set "LOG_FILE=%LOG_FILE:"=%"

if not exist "%LOG_FILE%" (
    echo [ERROR] File not found: %LOG_FILE%
    pause
    exit /b
)

REM Extract file name and directory
for %%I in ("%LOG_FILE%") do (
    set "LOG_DIR=%%~dpI"
    set "LOG_NAME=%%~nI"
)

REM Generate timestamp (YYYYMMDD_HHMMSS)
for /f "tokens=1-4 delims=/ " %%a in ("%date%") do (
    set yyyy=%%d
    set mm=%%b
    set dd=%%c
)
for /f "tokens=1-2 delims=:." %%a in ("%time%") do (
    set hh=%%a
    set min=%%b
)
set hh=0%hh%
set hh=!hh:~-2!
set min=0%min%
set min=!min:~-2!
set timestamp=!yyyy!!mm!!dd!_!hh!!min!

REM Ask for custom output directory (optional)
set /p OUTPUT_DIR=Enter output folder (leave blank for same folder): 
if "%OUTPUT_DIR%"=="" set "OUTPUT_DIR=%LOG_DIR%"

REM Ensure trailing backslash
if not "%OUTPUT_DIR:~-1%"=="\" set "OUTPUT_DIR=%OUTPUT_DIR%\"

set "OUTPUT_FILE=%OUTPUT_DIR%%LOG_NAME%_Trimmed_!timestamp!.txt"

echo [INFO] Trimming logs...
echo.

powershell -NoLogo -NoProfile -Command ^
  "$content = Get-Content -Raw '%LOG_FILE%';" ^
  "$pattern = '(?m)^(.*(LOG  : General|LOG  : Mo|LOG  : Network|DEBUG: General|WARN : Script|WARN : Recip|LOG  : Lua|AnimationAssetManager\.loadCallback|balObject\.require|AnimationPlayer\.play> Anim Clip not found|ImportedSkeleton\.collectBoneFrames> Could not find bone index for node name|DEBUG: Multiplayer|DEBUG: Voice|no GameSound|VehicleType\.initNormal> vehicle typ|no such function|Workshop: item state CheckItemState|ZomboidFileSystem\.loadModTileDefPropertyStrings|ZomboidFileSystem\.loadModTileDefs).*)$';" ^
  "$content -split '\r?\n' | Where-Object {$_ -notmatch $pattern} | Set-Content '%OUTPUT_FILE%';"

if %errorlevel% neq 0 (
    echo [ERROR] Failed to trim logs.
) else (
    echo [DONE] Trimmed logs saved to: %OUTPUT_FILE%
    start notepad.exe "%OUTPUT_FILE%"
)

pause
