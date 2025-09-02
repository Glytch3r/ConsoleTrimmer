@echo off
setlocal enabledelayedexpansion

REM Ask for the log file path
set /p LOG_FILE=Enter full path of console.txt: 

if not exist "%LOG_FILE%" (
    echo [ERROR] File not found: %LOG_FILE%
    pause
    exit /b
)

REM Ask for output file path
set /p OUTPUT_FILE=Enter output file path (leave blank for same folder): 

if "%OUTPUT_FILE%"=="" (
    for %%I in ("%LOG_FILE%") do set "OUTPUT_FILE=%%~dpIconsole_trimmed.txt"
)

echo [INFO] Trimming logs...
echo.

REM Run PowerShell with proper escaping
powershell -NoLogo -NoProfile -Command ^
  "$content = Get-Content -Raw '%LOG_FILE%';" ^
  "$pattern = '(?m)^(.*(LOG  : General|LOG  : Mo|LOG  : Network|DEBUG: General|WARN : Script|WARN : Recip|LOG  : Lua|AnimationAssetManager\.loadCallback|balObject\.require|AnimationPlayer\.play> Anim Clip not found|ImportedSkeleton\.collectBoneFrames> Could not find bone index for node name|DEBUG: Multiplayer|DEBUG: Voice|no GameSound|VehicleType\.initNormal> vehicle typ|no such function|Workshop: item state CheckItemState|ZomboidFileSystem\.loadModTileDefPropertyStrings|ZomboidFileSystem\.loadModTileDefs).*)$';" ^
  "$content -split '\r?\n' | Where-Object {$_ -notmatch $pattern} | Set-Content '%OUTPUT_FILE%';"

if %errorlevel% neq 0 (
    echo [ERROR] Failed to trim logs.
) else (
    echo [DONE] Trimmed logs saved to: %OUTPUT_FILE%
)

pause
