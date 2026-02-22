#!/system/bin/sh
#Universal script to install apk, apks and apkm

APK_NAME=$1
APK_PATH=$2
APK_CUT=$(echo $APK_NAME | cut -d '.' -f 2)
DOT_COUNT=$(echo $APK_NAME | grep -Fo "." | wc -m) 
TMP=$MODPATH/tmp
TOTAL_SIZE=0
I=0

if [[ "$APK_NAME" == '-h' ]] || [[ "$APK_NAME" = "help" ]]; then
 echo -e "HELP MENU \n use example: ./installAPK [APK_NAME] [APK_PATH] \n -h or help shows this menu"
 exit 0
fi

if [ "$DOT_COUNT" -gt 2 ]; then
 echo "The name must not have any dots but the one of the extension, execute again"
 exit 0
fi

if [ "$APK_CUT" = "apk" ]; then
 echo "normal APK detected, installing $APK_NAME in $APK_PATH"
 pm install $APK_PATH

elif [ "$APK_CUT" = "apks" ] || [ "$APK_CUT" = "apkm" ]; then
 echo "APK split detected, installing $APK_NAME in $APK_PATH"
 mkdir -p $TMP
 mv $APK_PATH $TMP/$APK_NAME.zip
 # DEBUG: make a backup
 cp $TMP/$APK_NAME.zip $TMP/..
 # DEBUG
 unzip -o $TMP/$APK_NAME.zip -d $TMP
 rm -rf $TMP/$APK_NAME.zip
 
 for APK in $MODPATH/tmp/*.apk; do
 
   SIZE=$(ls -l $APK | tr -s ' ' | cut -d ' ' -f 5)
   TOTAL_SIZE=$(( $TOTAL_SIZE + $SIZE ))
   
 done

 SESSION=$(pm install-create -S $TOTAL_SIZE | grep -Eo '[0-9]+')
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

