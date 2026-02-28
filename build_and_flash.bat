@echo off
setlocal enabledelayedexpansion

if exist "colors.bat" (
    call colors.bat
) else (
    echo Colors file could not be loaded
    exit /b 1
)

where adb >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo %BLUE%ADB not found on your pc, please install it%RESET%
    exit /b 1
)

:: Check if devices are connected
adb devices | findstr /r /c:"[0-9a-zA-Z][0-9a-zA-Z]*	device" >nul
if %ERRORLEVEL% neq 0 (
    echo %BLUE%There are not any ADB devices connected to the pc, please connect one%RESET%
    exit /b 1
)

set "ROOT=UNKNOWN"

adb shell su -c "magisk" >nul 2>nul
if %ERRORLEVEL% equ 0 (
    set "ROOT=magisk"
) else (
    :: Check KSU (KernelSU)
    adb shell su -c "ksud" >nul 2>nul
    if %ERRORLEVEL% equ 0 (
        set "ROOT=KSU"
    )
)

if "%ROOT%"=="UNKNOWN" (
    echo %RED%Unknown error: Could not detect Magisk or KSU%RESET%
    exit /b 1
)
echo Select your build version
echo %RED%1 for BETA%RESET%
echo %GREEN%2 for STABLE%RESET%

set /p SELECTION="Enter your selection: "

if "%SELECTION%"=="1" (
    echo %RED%building BETA version%RESET%
    echo.
    echo %RED%Building VK version%RESET%
    call gradlew :beta:zipRelease --no-configuration-cache
    
    echo %RED%Building no VK version%RESET%
    call gradlew :beta:novkzipRelease --no-configuration-cache
    
    echo %BLUE%Cleaning%RESET%
    call gradlew :beta:cleanDir --no-configuration-cache
    
    echo %BLUE%Pushing the zip to the phone%RESET%
    call gradlew :beta:pushVK

    echo %BLUE%Flashing%RESET%
    if "!ROOT!"=="magisk" (
        call gradlew :beta:flashMagiskVK
    ) else if "!ROOT!"=="KSU" (
        call gradlew :beta:flashKsuVK
    ) else (
        echo Unknown error during flash detection
    )

    echo %BLUE%Rebooting%RESET%
    call gradlew :beta:Reboot
    goto :SUCCESS
)

if "%SELECTION%"=="2" (
    echo %GREEN%building STABLE version%RESET%
    echo.
    echo %GREEN%Building VK version%RESET%
    call gradlew :stable:zipRelease --no-configuration-cache
    
    echo %GREEN%Building no VK version%RESET%
    call gradlew :stable:novkzipRelease --no-configuration-cache
    
    echo %BLUE%Cleaning%RESET%
    call gradlew :stable:cleanDir --no-configuration-cache
    
    echo %BLUE%Pushing the zip to the phone%RESET%
    call gradlew :stable:pushVK

    echo %BLUE%Flashing%RESET%
    if "!ROOT!"=="magisk" (
        call gradlew :stable:flashMagiskVK
    ) else if "!ROOT!"=="KSU" (
        call gradlew :stable:flashKsuVK
    ) else (
        echo Unknown error during flash detection
    )

    echo %BLUE%Rebooting%RESET%
    call gradlew :stable:Reboot
    goto :SUCCESS
)

echo No option selected, aborting
exit /b 1

echo.
echo %GREEN%Process Finished Successfully!%RESET%
pause
exit /b 0
