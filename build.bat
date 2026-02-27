@echo off
echo Select your build version
echo 1 for BETA
echo 2 for STABLE

:: /p allows a prompt string before the user types
set /p SELECTION="Enter your selection: "

if "%SELECTION%"=="1" (
    echo building BETA version
    call gradlew.bat :beta:assembleDebug --no-configuration-cache
) else if "%SELECTION%"=="2" (
    echo building STABLE version
    call gradlew.bat :stable:assembleDebug --no-configuration-cache
) else (
    echo No option selected, aborting
    exit /b 1
)

pause
