#!/system/bin/sh
#Universal script to install apk, apks and apkm

APK_NAME=$1
APK_PATH=$2
APK_CUT=$(echo $APK_NAME | cut -d '.' -f 2)
DOT_COUNT=$(echo $APK_NAME | grep -Fo "." | wc -m) 
if [[ $APK_PATH == '-h' ]] || [[ $APK_PATH = help ]]; then
 echo "HELP MENU \n use example: ./installAPK [APK_NAME] [APK_PATH] \n -h or help shows this menu"
 exit 0
fi

if [ $DOT_COUNT -gt 2 ]; then
 echo "The name must not have any dots but the one of the extension, execute again"
 exit 0
fi

if [ $APK_CUT == apk ]; then
 echo "normal APK detected, installing $APK_NAME in $APK_PATH"
 pm install $APK_PATH

elif [ $APK_CUT == apks ] || [ $APK_CUT == apkm ]; then
 echo "APK split detected, installing $APK_NAME in $APK_PATH"
 mkdir tmp
 mv $APK_PATH $MODPATH/tmp/$APKNAME.zip
 unzip -o $MODPATH/tmp/$APKNAME.zip

 for apk_size in $MODPATH/tmp/*.apk; do
   SIZE=$(ls -l $MODPATH/tmp | tr -s ' ' | cut -d ' ' -f 5)
   APK_SIZE=$( $APKSIZE + $SIZE )
 done

 SESSION=$(pm install-create -S $SIZE | grep -Eo '[0-9]+')
 echo "Session created with ID $SESSION and size $SIZE"

 I=0

for apk in $MODPATH/tmp/*.apk; do
 APK_SIZE_I=$(ls -l $MODPATH/tmp $APK | tr -s ' ' | cut -d ' ' -f 5) 
 INSTALL=$(pm install-write -S $APK_SIZE_I $SESSION $I $MODPATH/tmp/$APK)
 if [ $INSTALL != 0 ]; then
   echo "Failed to install $APK"
   exit 1
 fi
 I=$(I + 1)
done
else
 echo "Unkown extension, aborting"
 exit 0
fi

