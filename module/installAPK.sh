APK_NAME=$1
APK_PATH=$MODPATH/files/$APK_NAME
TMP_PATH=$MODPATH/files/tmp/$APK_NAME

ui_print ""
ui_print "Processing $APK_NAME "
ui_print ""

if [ ! -f $APK_PATH ]; then
 ui_print ""
 abort "APK not found in files, please reinstall and make sure the apk its there"
fi

if [ $APK_NAME = *.apk ]; then
 ui_print "normal APK detected, starting installation "
 ui_print ""
 pm install $APK_PATH
 
elif [[ $APK_NAME = *.apks ]] || [[ $APK_NAME = *.apkm ]]; then
 ui_print "split APK detected, starting installation "
 ui_print ""
 
 ID=$(pm install-create | grep -oE '[0-9]+')
 ui_print "Created installer session with id $ID"
 ui_print ""
 
 mkdir -p $TMP_PATH
 unzip -o $APK_PATH $TMP_PATH
 
 for apk_split in $TMP_PATH; do
  APK_SPLIT=*.apk
  APK_SIZE=$(stat -c%s $APK_SPLIT)
  pm install-write $ID $APK_SIZE $APK_SPLIT

else
 ui_print ""
 abort "Unkown extension, aborting"
fi
