@echo off
setlocal enabledelayedexpansion

where adb >nul 2>nul
if %errorlevel% neq 0 (
    echo ADB not found on your pc, please install it
    pause
    exit /b 1
)

set "DEVICE_FOUND=0"
for /f "tokens=1,2" %%a in ('adb devices') do (
    if "%%b"=="device" set "DEVICE_FOUND=1"
)
if %DEVICE_FOUND% equ 0 (
    echo There aren't any ADB devices connected to the pc, please connect one
    pause
    exit /b 1
)

set "ROOT=UNKNOWN"
adb shell su -c "magisk -v" >nul 2>nul
if %errorlevel% equ 0 (
    set "ROOT=magisk"
) else (
    adb shell su -c "ksud --version" >nul 2>nul
    if %errorlevel% equ 0 (
        set "ROOT=KSU"
    )
)

if "%ROOT%"=="UNKNOWN" (
    echo Unknown error: Could not detect Magisk or KSU
    pause
    exit /b 1
)

echo Select your build version
echo 1 for BETA
echo 2 for STABLE
set /p SELECTION="Enter your selection: "

if "%SELECTION%"=="1" (
    set "VER=beta"
) else if "%SELECTION%"=="2" (
    set "VER=stable"
) else (
    echo No option selected, aborting
    pause
    exit /b 1
)

echo building %VER% version
 echo Building VK version
 ./gradlew :%VER%:zipRelease --no-configuration-cache
 echo Building no VK version
 ./gradlew :%VER%:novkzipRelease --no-configuration-cache
 echo Cleaning
 ./gradlew :%VER%:cleanDir --no-configuration-cache
 
if %errorlevel% neq 0 exit /b 1

call gradlew.bat :%VER%:pushVK

if "%ROOT%"=="magisk" (
    echo Flashing
    call gradlew.bat :%VER%:flashMagiskVK
) else (
    echo Flashing
    call gradlew.bat :%VER%:flashKsuVK
)
echo Rebooting
call gradlew.bat :%VER%:Reboot

echo Done!
pause
