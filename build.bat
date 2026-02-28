@echo off
echo Select your build version
echo 1 for BETA
echo 2 for STABLE

:: /p allows a prompt string before the user types
set /p SELECTION="Enter your selection: "

if "%SELECTION%"=="1" (
    echo building BETA version
    echo ""
    echo Building VK version
    call gradlew :beta:zipRelease --no-configuration-cache
    echo Building no VK version
    call gradlew :beta:novkzipRelease --no-configuration-cache
    echo Cleaning
    call gradlew :beta:cleanDir --no-configuration-cache
) else if "%SELECTION%"=="2" (
    echo building STABLE version
    echo ""
    echo Building VK version
    call gradlew :stable:zipRelease --no-configuration-cache
    echo Building no VK version
    call gradlew :stable:novkzipRelease --no-configuration-cache
    echo Cleaning
    call gradlew :stable:cleanDir --no-configuration-cache
) else (
    echo No option selected, aborting
    exit /b 1
)

pause
