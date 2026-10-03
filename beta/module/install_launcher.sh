install_pixel_launcher() {
    if [ $API -ge 36 ]; then
        ui_print ""
        ui_print "  Do you want to install Pixel Launcher? (Android 16 only)"
        ui_print "   Vol Up += Yes"
        ui_print "   Vol Down += No"
        no_vk "ENABLE_PIXEL_LAUNCHER"
        if $VKSEL; then
            ui_print " - Installing Pixel Launcher"
            log " - Installing Pixel Launcher"

            PL=$(find /system -name *Launcher* | grep -v overlay | grep -v Nexus | grep -v bin | grep -v "\.")
            TR=$(find /system -name *Trebuchet* | grep -v overlay | grep -v "\.")
            QS=$(find /system -name *QuickStep* | grep -v overlay | grep -v "\.")
            LW=$(find /system -name *MiuiHome* | grep -v overlay | grep -v "\.")
            TW=$(find /system -name *TouchWizHome* | grep -v overlay | grep -v "\.")
            KW=$(find /system -name *Lawnchair* | grep -v overlay | grep -v "\.")

            REMOVE="$REMOVE $PL $TR $QS $LW $TW $KW"

            if [ -f $MODPATH/system/product/priv-app/DevicePersonalizationPrebuiltPixel2025/DevicePersonalizationPrebuiltPixel2025.zip ]; then
                unzip -o $MODPATH/system/product/priv-app/DevicePersonalizationPrebuiltPixel2025/DevicePersonalizationPrebuiltPixel2025.zip -d $MODPATH/system/product/priv-app/DevicePersonalizationPrebuiltPixel2025 2>/dev/null || true
            fi

            set_perm_recursive $MODPATH/system/etc 0 0 0755 0644
            set_perm_recursive $MODPATH/system/product/app 0 0 0755 0644
            set_perm_recursive $MODPATH/system/product/etc 0 0 0755 0644
            set_perm_recursive $MODPATH/system/product/media 0 0 0755 0644
            set_perm_recursive $MODPATH/system/product/overlay 0 0 0755 0644
            set_perm_recursive $MODPATH/system/product/priv-app 0 0 0755 0644
            [ -d $MODPATH/system/product/app ] && set_contexts $MODPATH/system/product/app u:object_r:product_app_file:s0 2>/dev/null || true
            [ -d $MODPATH/system/product/etc/permissions ] && set_contexts $MODPATH/system/product/etc/permissions u:object_r:product_etc_file:s0 2>/dev/null || true
            [ -d $MODPATH/system/product/media ] && set_contexts $MODPATH/system/product/media u:object_r:product_media_file:s0 2>/dev/null || true
            [ -d $MODPATH/system/product/overlay ] && set_contexts $MODPATH/system/product/overlay u:object_r:product_overlay_file:s0 2>/dev/null || true
            [ -d $MODPATH/system/product/priv-app ] && set_contexts $MODPATH/system/product/priv-app u:object_r:product_priv_app_file:s0 2>/dev/null || true

            # Auto-set Pixel Launcher as default home launcher on boot
            echo "cmd package set-home-activity com.google.android.apps.nexuslauncher/.NexusLauncherActivity 2>/dev/null || true" >> $MODPATH/service.sh
            echo "cmd role add-role-holder android.app.role.HOME com.google.android.apps.nexuslauncher 2>/dev/null || true" >> $MODPATH/service.sh
        else
            ui_print " - Skipping Pixel Launcher"
            log " - Skipping Pixel Launcher"
            # Thorough cleanup of all Pixel Launcher files & leftovers
            rm -rf $MODPATH/system/product/priv-app/NexusLauncherRelease 2>/dev/null
            rm -rf $MODPATH/system/product/priv-app/DevicePersonalizationPrebuiltPixel* 2>/dev/null
            rm -rf $MODPATH/system/product/app/NexusLauncher* 2>/dev/null
            rm -rf $MODPATH/system/product/overlay/*NexusLauncher* 2>/dev/null
            rm -rf $MODPATH/system/product/overlay/*Launcher* 2>/dev/null
            rm -rf $MODPATH/system/product/etc/permissions/com.google.android.apps.nexuslauncher.xml 2>/dev/null
            rm -rf $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.apps.nexuslauncher.xml 2>/dev/null
            rm -rf $MODPATH/system/product/etc/sysconfig/hiddenapi-whitelist-com.google.android.apps.nexuslauncher.xml 2>/dev/null
        fi
    else
        ui_print " - Skipping Pixel Launcher (Requires API 36 / Android 16)"
        log " - Skipping Pixel Launcher due to API $API"
        rm -rf $MODPATH/system/product/priv-app/NexusLauncherRelease 2>/dev/null
        rm -rf $MODPATH/system/product/priv-app/DevicePersonalizationPrebuiltPixel* 2>/dev/null
        rm -rf $MODPATH/system/product/app/NexusLauncher* 2>/dev/null
        rm -rf $MODPATH/system/product/overlay/*NexusLauncher* 2>/dev/null
        rm -rf $MODPATH/system/product/overlay/*Launcher* 2>/dev/null
        rm -rf $MODPATH/system/product/etc/permissions/com.google.android.apps.nexuslauncher.xml 2>/dev/null
        rm -rf $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.apps.nexuslauncher.xml 2>/dev/null
        rm -rf $MODPATH/system/product/etc/sysconfig/hiddenapi-whitelist-com.google.android.apps.nexuslauncher.xml 2>/dev/null
    fi
}
