#!/bin/bash

echo "Select your build version"
echo "1 for BETA"
echo "2 for STABLE"
read -p "Enter your selection: " SELECTION
case $SELECTION in
"1")
 echo "building BETA version"
 ./gradlew :beta:zipRelease --no-configuration-cache
 ./gradlew :beta:novkzipRelease --no-configuration-cache
 ;;
"2")
 echo "building STABLE version"
 ./gradlew :stable:zipRelease --no-configuration-cache
 ./gradlew :stable:novkzipRelease --no-configuration-cache
 ;;
*)
 echo "No option selected, aborting"
 exit 1
 ;;
esac
