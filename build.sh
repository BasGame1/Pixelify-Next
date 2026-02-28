#!/bin/bash

source colors.sh || echo "Colors file could not be loaded"

yellow "Select your build version"
red "1 for BETA"
green "2 for STABLE"
read -p "Enter your selection: " SELECTION
case $SELECTION in
"1")
 red "building BETA version"
 echo ""
 red "Building VK version"
 ./gradlew :beta:zipRelease --no-configuration-cache
 red "Building no VK version"
 ./gradlew :beta:novkzipRelease --no-configuration-cache
 blue "Cleaning"
 ./gradlew :beta:cleanDir --no-configuration-cache
 ;;
"2")
 green "building STABLE version"
 echo ""
 green "Building VK version"
 ./gradlew :stable:zipRelease --no-configuration-cache
 green "Building no VK version"
 ./gradlew :stable:novkzipRelease --no-configuration-cache
 blue "Cleaning"
 ./gradlew :stable:cleanDir --no-configuration-cache
 ;;
*)
 blue "No option selected, aborting"
 exit 1
 ;;
esac
