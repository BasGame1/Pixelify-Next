# Universal script to install apk, apks and apkm
install_apk() {
APK_NAME=$1
APK_PATH=$2
ABI=$3
APK_CUT=$(echo $APK_NAME | cut -d '.' -f 2)
DOT_COUNT=$(echo $APK_NAME | grep -Fo "." | wc -m) 
TMP=$MODPATH/tmp
TOTAL_SIZE=0
I=0

if [ "$APK_NAME" = "-h" ] || [ "$APK_NAME" = "help" ]; then
 echo -e "HELP MENU \n use example: ./installAPK [APK_NAME] [APK_PATH] [ABI - SELECT ARM64 OR ARM32]\n -h or help shows this menu"
 exit 0
fi

if [ "$DOT_COUNT" -gt 2 ]; then
 echo "The name must not have any dots but the one of the extension, execute again"
 exit 0
fi

if [ "$APK_CUT" = "apk" ]; then
 echo "normal APK detected, installing $APK_NAME in $APK_PATH"
 if [ "$ABI" = "arm64" ]; then
  echo "Installing with ABI arm64"
  pm install --abi arm64-v8a $APK_PATH
 elif [ "$ABI" = "arm32" ]; then
  echo "Installing with ABI arm32"
  pm install --abi armabi-v7a $APK_PATH
 else
  echo "Installing without ABI"
  pm install $APK_PATH
 fi
elif [ "$APK_CUT" = "apks" ] || [ "$APK_CUT" = "apkm" ]; then
 echo "APK split detected, installing $APK_NAME in $APK_PATH"
 mkdir -p $TMP
 mv $APK_PATH $TMP/$APK_NAME.zip
 unzip -o $TMP/$APK_NAME.zip -d $TMP
 rm -rf $TMP/$APK_NAME.zip
 
 for APK in $MODPATH/tmp/*.apk; do
 
   SIZE=$(ls -l $APK | tr -s ' ' | cut -d ' ' -f 5)
   TOTAL_SIZE=$(( $TOTAL_SIZE + $SIZE ))
   
 done
 
 if [ "$ABI" = "arm64" ]; then
  echo "Creating session with ABI arm64"
  SESSION=$(pm install-create --abi arm64-v8a -S $TOTAL_SIZE | grep -Eo '[0-9]+')
 elif [ "$ABI" = "arm32" ]; then
  echo "Creating session with ABI arm32"
  SESSION=$(pm install-create --abi armabi-v7a -S $TOTAL_SIZE | grep -Eo '[0-9]+')
 else
  echo "Creating session without ABI"
  SESSION=$(pm install-create -S $TOTAL_SIZE | grep -Eo '[0-9]+')
 fi
 
 echo "Session created with ID $SESSION and size $TOTAL_SIZE"

 for APK in $MODPATH/tmp/*.apk; do

  APK_SIZE_I=$(ls -l $APK | tr -s ' ' | cut -d ' ' -f 5) 
  APK_BASE=$(basename "$APK")
  INSTALL=$(pm install-write -S $APK_SIZE_I $SESSION $APK_BASE $APK)
  
  if [ $? -ne 0 ]; then
    echo "Failed to install $APK_NAME"
    rm -rf $TMP
    pm install-abandon $SESSION
    exit 1
  fi
  
  I=$((I + 1))
  
 done

 pm install-commit $SESSION
 rm -rf $TMP

else

 echo "Unkown extension, aborting"
 exit 1
 
fi
}

if [ "$1" = "standalone" ]; then
    install_apk "$@"
fi
