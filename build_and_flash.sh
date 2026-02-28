#!/bin/bash

source colors.sh || echo "Colors file could not be loaded"

if [ $(adb shell su -c "magisk") ]; then
 ROOT=magisk
elif [ $(adb shell su -c "ksud") ]; then
 ROOT=KSU
elif [ ! command -v "adb" 2>/dev/null ]; then
 blue "ADB not found on your pc, please install it"
 exit 1
elif [ ! $(adb devices) 2>/dev/null ]; then
 blue "There aren't any ADB devices connected to the pc, please connect one"
 exit 1
else
 echo "Unkown error"
 exit 1
fi

echo "Select your build version"
red "1 for BETA"
green "2 for STABLE"
read -p "Enter your selection: " SELECTION
case $SELECTION in
"1")
 red "building BETA version"
 .echo ""
 red "Building VK version"
 ./gradlew :beta:zipRelease --no-configuration-cache
 red "Building no VK version"
 ./gradlew :beta:novkzipRelease --no-configuration-cache
 blue "Cleaning"
 ./gradlew :beta:cleanDir --no-configuration-cache
 blue "Pushing the zip to the phone"
 ./gradlew :beta:pushVK
 if [[ $ROOT == "magisk" ]]; then
 blue "Flashing"
 ./gradlew :beta:flashMagiskVK
 elif [[ $ROOT == "KSU" ]]; then
 blue "Flashing"
 ./gradlew :beta:flashKsuVK
 else
  echo "Unkown error"
 fi
 blue "Rebooting"
 ./gradlew :beta:Reboot
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
 blue "Pushing the zip to the phone"
 ./gradlew :stable:pushVK
 if [[ $ROOT == "magisk" ]]; then
 blue "Flashing"
 ./gradlew :stable:flashMagiskVK
 elif [[ $ROOT == "KSU" ]]; then
 blue "Flashing"
 ./gradlew :stable:flashKsuVK
 else
  echo "Unkown error"
 fi
 blue "Rebooting"
 ./gradlew :stable:Reboot
 ;;
*)
 echo "No option selected, aborting"
 exit 1
 ;;
esac
