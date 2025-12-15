ui_print "*********************************"
ui_print "Installing Pixelify Next Luancher"
ui_print "*********************************"
ui_print ""
ui_print "Unzipping"
unzip -o $MODPATH/PLauncher.zip

ui_print "- Setting permissions"

# Set perms for /system/etc/
set_perm_recursive $MODPATH/system/etc 0 0 0755 0644

# Set perms for all subdirectories in /system/product/
set_perm_recursive $MODPATH/system/product/app 0 0 0755 0644
set_perm_recursive $MODPATH/system/product/etc 0 0 0755 0644
set_perm_recursive $MODPATH/system/product/media 0 0 0755 0644
set_perm_recursive $MODPATH/system/product/overlay 0 0 0755 0644
set_perm_recursive $MODPATH/system/product/priv-app 0 0 0755 0644

ui_print "- Setting SELinux contexts"

# Context for /system/etc/sysconfig/
set_contexts $MODPATH/system/etc/sysconfig u:object_r:system_sysconfig_file:s0

# Context for /system/product/app/
set_contexts $MODPATH/system/product/app u:object_r:product_app_file:s0

# Context for /system/product/etc/permissions/
set_contexts $MODPATH/system/product/etc/permissions u:object_r:product_etc_file:s0

# Context for /system/product/media/
set_contexts $MODPATH/system/product/media u:object_r:product_media_file:s0

# Context for /system/product/overlay/
set_contexts $MODPATH/system/product/overlay u:object_r:product_overlay_file:s0

# Context for /system/product/priv-app/
set_contexts $MODPATH/system/product/priv-app u:object_r:product_priv_app_file:s0

if [ -d $MODPATH/system ]; then
rm $MODPATH/PLauncher.zip
fi

ui_print "*********************************"
ui_print "   Installation complete! "
ui_print "   Reboot to apply changes.    "
ui_print "*********************************"

# Thanks to Meowna and Tristan for the apks :)
