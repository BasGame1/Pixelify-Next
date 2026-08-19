@echo off
set "REPO_ROOT=%~dp0..\mosey-p8a"
set "OUT_DIR=%REPO_ROOT%\out\zip"
set "MODULE_OUT=%REPO_ROOT%\out\module"

echo Creating zip out folder...
mkdir "%OUT_DIR%" 2>nul

:: Copy files
if exist "%MODULE_OUT%\wonder_mosey_wild.ko" (
    copy /Y "%MODULE_OUT%\wonder_mosey_wild.ko" "%OUT_DIR%\" >nul
) else if exist "%REPO_ROOT%\system\vendor\lib\modules\wonder_mosey_wild.ko" (
    mkdir "%MODULE_OUT%" 2>nul
    copy /Y "%REPO_ROOT%\system\vendor\lib\modules\wonder_mosey_wild.ko" "%MODULE_OUT%\wonder_mosey_wild.ko" >nul
    copy /Y "%MODULE_OUT%\wonder_mosey_wild.ko" "%OUT_DIR%\" >nul
) else (
    echo Error: wonder_mosey_wild.ko missing, exiting
    exit /b 255
)

copy /Y "%REPO_ROOT%\customize.sh" "%OUT_DIR%\" >nul
copy /Y "%REPO_ROOT%\module.prop" "%OUT_DIR%\" >nul
copy /Y "%REPO_ROOT%\sepolicy.rule" "%OUT_DIR%\" >nul
copy /Y "%REPO_ROOT%\service.sh" "%OUT_DIR%\" >nul
copy /Y "%REPO_ROOT%\uninstall.sh" "%OUT_DIR%\" >nul

:: Copy folders
xcopy /E /I /Y "%REPO_ROOT%\common" "%OUT_DIR%\common" >nul
xcopy /E /I /Y "%REPO_ROOT%\META-INF" "%OUT_DIR%\META-INF" >nul
xcopy /E /I /Y "%REPO_ROOT%\payload" "%OUT_DIR%\payload" >nul
xcopy /E /I /Y "%REPO_ROOT%\system" "%OUT_DIR%\system" >nul
