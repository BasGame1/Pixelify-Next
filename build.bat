@echo off
setlocal enabledelayedexpansion

if exist "colors.bat" (
    call colors.bat
) else (
    echo Colors file could not be loaded
    exit /b 1
)

echo %YELLOW%Select your build version%RESET%
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
    goto :EOF
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
    goto :EOF
)

echo %BLUE%No option selected, aborting%RESET%
exit /b 1
