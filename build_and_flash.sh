#!/bin/bash

if [ $(adb shell su -c "magisk") ]; then
 ROOT=magisk
elif [ $(adb shell su -c "ksud") ]; then
 ROOT=KSU
elif [ ! command -v "adb" ]; then
 echo "ADB not found on your pc, please install it"
 exit 1
elif [ ! $(adb devices) ]; then
 echo "There aren't any ADB devices connected to the pc, please connect one"
 exit 1
else
 echo "Unkown error"
 exit 1
fi

echo "Select your build version"
echo "1 for BETA"
echo "2 for STABLE"
read -p "Enter your selection: " SELECTION
case $SELECTION in
"1")
 echo "building BETA version"
 ./gradlew :beta:build --no-configuration-cache
 ./gradlew :beta:pushVK
 if [[ $ROOT == "magisk" ]]; then
 ./gradlew :beta:flashMagiskVK
 elif [[ $ROOT == "KSU" ]]; then
 ./gradlew :beta:flashKsuVK
 else
  echo "Unkown error"
 fi
 ./gradlew :beta:Reboot
 ;;
"2")
 echo "building STABLE version"
 ./gradlew :stable:build --no-configuration-cache
  ./gradlew :stable:pushVK
 if [[ $ROOT == "magisk" ]]; then
 ./gradlew :stable:flashMagiskVK
 elif [[ $ROOT == "KSU" ]]; then
 ./gradlew :stable:flashKsuVK
 else
  echo "Unkown error"
 fi
 ./gradlew :stable:Reboot
 ;;
*)
 echo "No option selected, aborting"
 exit 1
 ;;
esac
