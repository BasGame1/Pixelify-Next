#!/bin/bash

set -e

source colors.sh 2>/dev/null || echo -e "\033[0;31m[ERROR]\033[0m Colors file could not be loaded"

user_option() {
yellow "Select your build version"
echo ""
echo -e "\033[1;33m1) \033[0;34mBeta\033[0m"
echo -e "\033[1;33m2) \033[0;34mStable\033[0m"
echo ""
read -n 1 -p "Enter your selection: " SELECTION
echo ""
case $SELECTION in
"1")
 info "building BETA version"
 echo ""
 info "Building VK version"
 ./gradlew :beta:zipRelease --no-configuration-cache
 info "Building no VK version"
 ./gradlew :beta:novkzipRelease --no-configuration-cache
 info "Cleaning"
 ./gradlew :beta:cleanDir --no-configuration-cache
 success "All done!"
 exit
 ;;
"2")
 info "building STABLE version"
 info "Building VK version"
 ./gradlew :stable:zipRelease --no-configuration-cache
 info "Building no VK version"
 ./gradlew :stable:novkzipRelease --no-configuration-cache
 info "Cleaning"
 ./gradlew :stable:cleanDir --no-configuration-cache
 success "All done!"
 exit
 ;;
*)
 error "No option selected, aborting"
 exit 1
 ;;
esac
}
if [ ! -z $1 ]; then
while getopts "bsa" OPTIONS; do
 case $OPTIONS in
  b)
   info "Beta: building VK version"
   ./gradlew :beta:zipRelease --no-configuration-cache
   info "Beta: building no VK version"
   ./gradlew :beta:novkzipRelease --no-configuration-cache
   info "Beta: cleaning"
   ./gradlew :beta:cleanDir --no-configuration-cache
   success "All Done!"
  ;;
  s)
   info "Stable: building VK version"
   ./gradlew :stable:zipRelease --no-configuration-cache
   info "Stable: building no VK version"
   ./gradlew :stable:novkzipRelease --no-configuration-cache
   info "Stable: cleaning"
   ./gradlew :stable:cleanDir --no-configuration-cache
   success "All Done!"
  ;;
  a)
   info "Building all"
   info "Stable: building VK version"
   ./gradlew :stable:zipRelease --no-configuration-cache
   info "Stable: building no VK version"
   ./gradlew :stable:novkzipRelease --no-configuration-cache
   info "Stable: cleaning"
   ./gradlew :stable:cleanDir --no-configuration-cache
   info "Beta: building VK version"
   ./gradlew :beta:zipRelease --no-configuration-cache
   info "Beta: building no VK version"
   ./gradlew :beta:novkzipRelease --no-configuration-cache
   info "Beta: cleaning"
   ./gradlew :beta:cleanDir --no-configuration-cache
   success "All Done!"
  ;;
  *)
   error "Unkown argument $OPTION, exiting"
   exit 255
  ;;
 esac
done
else
 info "No arguments, runnign decision"
 user_option
 exit
fi
