@echo off
setlocal enabledelayedexpansion

:: ROOT_DIR is the project root directory
set "ROOT_DIR=%cd%"

:: First argument is the build directory path, default to out\magisk_module_beta_release
set "PN_BUILD=%~1"
if "%PN_BUILD%"=="" set "PN_BUILD=%ROOT_DIR%\out\magisk_module_beta_release"

:: Check if mosey submodule is present
if not exist "%ROOT_DIR%\mosey-p8a\build_mosey.sh" (
    echo Warning: mosey-p8a submodule is not cloned or missing. Skipping Mosey build.
    exit /b 0
)

set "WONDER_OUT=%ROOT_DIR%\mosey-p8a\out\module"
set "MOSEY_OUT=%ROOT_DIR%\mosey-p8a\out\zip"

:: 1. Compile wonder if needed
if not exist "%WONDER_OUT%\wonder_mosey_wild.ko" (
    echo Building Wonder...
    call "%ROOT_DIR%\scripts\build_wonder.bat"
    echo Wonder built!
) else (
    echo Wonder already built, skipping
)

:: 2. Create mosey structure if needed
if not exist "%MOSEY_OUT%\module.prop" (
    echo Mosey not found, creating structure...
    call "%ROOT_DIR%\scripts\build_mosey_sub.bat"
    echo Mosey structure created!
) else (
    echo Mosey in position to copy
)

:: 3. Copy/merge files to PN_BUILD
echo Copying Mosey folders to %PN_BUILD%
xcopy /E /I /Y "%MOSEY_OUT%\common" "%PN_BUILD%\common" >nul 2>&1
xcopy /E /I /Y "%MOSEY_OUT%\payload" "%PN_BUILD%\payload" >nul 2>&1
xcopy /E /I /Y "%MOSEY_OUT%\system" "%PN_BUILD%\system" >nul 2>&1

if exist "%MOSEY_OUT%\wonder_mosey_wild.ko" (
    mkdir "%PN_BUILD%\system\vendor\lib\modules" 2>nul
    copy /Y "%MOSEY_OUT%\wonder_mosey_wild.ko" "%PN_BUILD%\system\vendor\lib\modules\" >nul
)

:: 4. Patch files
powershell -Command "if (Test-Path '%PN_BUILD%\customize.sh') { (Get-Content '%PN_BUILD%\customize.sh') -replace '#CUSTOMIZE.SH_MOSEY_STUB', [System.IO.File]::ReadAllText('%MOSEY_OUT%\customize.sh') | Set-Content '%PN_BUILD%\customize.sh' }"
powershell -Command "if (Test-Path '%PN_BUILD%\service.sh') { (Get-Content '%PN_BUILD%\service.sh') -replace '#SERVICE.SH_MOSEY_STUB', [System.IO.File]::ReadAllText('%MOSEY_OUT%\service.sh') | Set-Content '%PN_BUILD%\service.sh' }"
powershell -Command "if (Test-Path '%PN_BUILD%\uninstall.sh') { (Get-Content '%PN_BUILD%\uninstall.sh') -replace '#UNINSTALLER.SH_MOSEY_STUB', [System.IO.File]::ReadAllText('%MOSEY_OUT%\uninstall.sh') | Set-Content '%PN_BUILD%\uninstall.sh' }"

:: 5. Set built with mosey support flag
powershell -Command "if (Test-Path '%PN_BUILD%\vars.sh') { (Get-Content '%PN_BUILD%\vars.sh') -replace 'BUILT_WITH_MOSEY_SUPPORT=0', 'BUILT_WITH_MOSEY_SUPPORT=1' | Set-Content '%PN_BUILD%\vars.sh' }"

:: 6. Credits
powershell -Command "if (Test-Path 'beta\module\module.prop') { $content = Get-Content 'beta\module\module.prop'; if ($content -notmatch 'lok1s') { Add-Content 'beta\module\module.prop' \"`n# Credits to lok1s for mosey`n# He is the original creator of the mosey module\" } }"

exit /b 0
