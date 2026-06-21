install_pixel_launcher() {
 if [ $API -ge 36 ]; then
    PL=$(find /system -name *Launcher* | grep -v overlay | grep -v Nexus | grep -v bin | grep -v "\.")
    TR=$(find /system -name *Trebuchet* | grep -v overlay | grep -v "\.")
    QS=$(find /system -name *QuickStep* | grep -v overlay | grep -v "\.")
    LW=$(find /system -name *MiuiHome* | grep -v overlay | grep -v "\.")
    TW=$(find /system -name *TouchWizHome* | grep -v overlay | grep -v "\.")
    KW=$(find /system -name *Lawnchair* | grep -v overlay | grep -v "\.")

            REMOVE="$REMOVE $PL $TR $QS $LW $TW $KW"
        log "  Do you want to install Pixel Launcher? (Android 16 only)"
        log "   Vol Up += Yes"
        log "   Vol Down += No"
        no_vk "ENABLE_PIXEL_LAUNCHER"
        if $VKSEL; then
                log "- Installing Pixel Launcher"
                echo " - Installing Pixel Launcher" >>$logfile
                log ""
                unzip -o $MODPATH/system/product/priv-app/DevicePersonalizationPrebuiltPixel2025/DevicePersonalizationPrebuiltPixel2025.zip $MODPATH/system/product/priv-app/DevicePersonalizationPrebuiltPixel2025
                set_perm_recursive $MODPATH/system/etc 0 0 0755 0644
                set_perm_recursive $MODPATH/system/product/app 0 0 0755 0644
                set_perm_recursive $MODPATH/system/product/etc 0 0 0755 0644
                set_perm_recursive $MODPATH/system/product/media 0 0 0755 0644
                set_perm_recursive $MODPATH/system/product/overlay 0 0 0755 0644
                set_perm_recursive $MODPATH/system/product/priv-app 0 0 0755 0644
                set_contexts $MODPATH/system/etc/sysconfig u:object_r:system_sysconfig_file:s0
                set_contexts $MODPATH/system/product/app u:object_r:product_app_file:s0
                set_contexts $MODPATH/system/product/etc/permissions u:object_r:product_etc_file:s0
                set_contexts $MODPATH/system/product/media u:object_r:product_media_file:s0
                set_contexts $MODPATH/system/product/overlay u:object_r:product_overlay_file:s0
                set_contexts $MODPATH/system/product/priv-app u:object_r:product_priv_app_file:s0
                REMOVE="$REMOVE $PL $TR $QS $LW $TW $KW"
        else
            echo " - Deleting Pixel Launcher" >>$logfile
            for FILE in $MODPATH/system/*.apk; do
                rm -rf $FILE 2>/dev/null
            done
            for FILE in $MODPATH/system/product/etc/permissions/com.android.systemui.plugin.globalactions.wallet.xml $MODPATH/system/product/etc/permissions/com.android.systemui.plugin.globalactions.wallet.xml $MODPATH/system/product/etc/permissions/com.google.android.apps.nexuslauncher.xml $MODPATH/system/product/etc/permissions/com.google.android.apps.wallpaper.xml $MODPATH/system/product/etc/permissions/com.google.android.apps.weather.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.apps.nexuslauncher.xml; do
                rm -rf $FILE 2>/dev/null
            done
            rm -rf $MODPATH/system/product/priv-app/DevicePersonalizationPrebuiltPixel2025

        fi
else
    echo " - Skipping Pixel Launcher because you dont have Android 16" >>$logfile
    for FILE in $(find "$MODPATH/system" -type f -name "*.apk"); do
        rm -rf $FILE 2>/dev/null
    done
    rm -rf $MODPATH/system/product/priv-app/DevicePersonalizationPrebuiltPixel2024
else
 ui_print "You cannot install Pixel Launcher due to being on api $API"
fi
}
