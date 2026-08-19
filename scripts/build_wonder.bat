@echo off
set "SCRIPT_DIR=%~dp0"
set "REPO_ROOT=%SCRIPT_DIR%..\mosey-p8a"
set "OUT_DIR=%REPO_ROOT%\out\module"
set "MODULE_SYS_DIR=%REPO_ROOT%\system\vendor\lib\modules"
set "MODULE_BIN_DIR=%REPO_ROOT%\system\vendor\bin"

mkdir "%OUT_DIR%" "%MODULE_SYS_DIR%" "%MODULE_BIN_DIR%" 2>nul

echo [+] Building rename_phy binary (aarch64 static)...
where aarch64-linux-gnu-gcc >nul 2>&1
if %ERRORLEVEL% equ 0 (
    aarch64-linux-gnu-gcc -O2 -static "%REPO_ROOT%\wonder\rename_phy.c" -o "%MODULE_BIN_DIR%\rename_phy"
    echo [+] rename_phy built: %MODULE_BIN_DIR%\rename_phy
) else (
    echo [-] aarch64-linux-gnu-gcc not found, skipping rename_phy cross-compilation
)

echo [+] Checking wonder_mosey_wild.ko module...
where aarch64-linux-gnu-gcc >nul 2>&1
if %ERRORLEVEL% equ 0 (
    echo [+] Cross-compiling wonder_mosey_wild.ko for ARM64...
    aarch64-linux-gnu-gcc -O2 -c -fno-pic "%REPO_ROOT%\wonder\wonder_mosey_wild.c" -o "%MODULE_SYS_DIR%\wonder_mosey_wild.ko"
    if exist "%MODULE_SYS_DIR%\wonder_mosey_wild.ko" (
        copy /Y "%MODULE_SYS_DIR%\wonder_mosey_wild.ko" "%OUT_DIR%\wonder_mosey_wild.ko" >nul
    )
) else (
    echo Warning: aarch64-linux-gnu-gcc not found, cannot build wonder_mosey_wild.ko
)
