@echo off
setlocal enabledelayedexpansion

set /p LOG_FILE=Enter full path of console.txt: 

if not exist "%LOG_FILE%" (
    echo [ERROR] File not found: %LOG_FILE%
    pause
    exit /b
)

set /p OUTPUT_FILE=Enter output file path (leave blank for auto _trim.txt): 

if "%OUTPUT_FILE%"=="" (
    for %%I in ("%LOG_FILE%") do set "OUTPUT_FILE=%%~dpnI_trim.txt"
)

echo [INFO] Trimming logs...
echo.

set "psCommand=$logFile = '%LOG_FILE%'; $outFile = '%OUTPUT_FILE%'; $content = Get-Content -Raw $logFile; $pattern = '(?m)^(.*(LOG  : General|IsoWorld.LoadTileDefinitions|not used by any GameSound|TextManager.Init> font|No such FMOD event|LOG  : Mo|LOG  : Network|DEBUG: General|WARN : Script|WARN : Recip|LOG  : Lua|AnimationAssetManager\.loadCallback|balObject\.require|AnimationPlayer\.play> Anim Clip not found|ImportedSkeleton\.collectBoneFrames> Could not find bone index for node name|DEBUG: Multiplayer|DEBUG: Voice|no GameSound|VehicleType\.initNormal> vehicle typ|no such function|Workshop: item state CheckItemState|ZomboidFileSystem\.loadModTileDefPropertyStrings|ZomboidFileSystem\.loadModTileDefs).*)$'; $content -split '\r?\n' | Where-Object {$_ -notmatch $pattern} | Set-Content -Path $outFile"

powershell -NoLogo -NoProfile -Command "!psCommand!"

if %errorlevel% neq 0 (
    echo [ERROR] Failed to trim logs.
) else (
    echo [DONE] Trimmed logs saved to: %OUTPUT_FILE%
)

pause
