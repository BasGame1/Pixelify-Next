systemize_velvet() {
        if [ -z $(pm list packages -s com.google.android.googlequicksearchbox | grep -v nga) ] && [ ! -f /data/adb/modules/PixelifyNext/system/product/priv-app/Velvet/Velvet.apk ] || [ $FORCE_VELVET -eq 1 ]; then
            error "- Google is not installed as a system app !!"
            log "- Making Google a system app"
            log " - Making Google a system app"
            log ""
            if [ -f $app/com.google.android.googlequicksearchbox*/base.apk ]; then
                cp -r $app/com.google.android.googlequicksearchbox*/. $MODPATH/system/product/priv-app/Velvet
                mv $MODPATH/system/product/priv-app/Velvet/base.apk $MODPATH/system/product/priv-app/Velvet/Velvet.apk
            else
                cp -r /data/adb/modules/PixelifyNext/system$product/priv-app/Velvet/. $MODPATH/system$product/priv-app/Velvet
            fi
            rm -rf $MODPATH/system/product/priv-app/Velvet/oat
            #mv $MODPATH/files/privapp-permissions-com.google.android.googlequicksearchbox.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.googlequicksearchbox.xml

        # If Pixelify made system app then remake it
        elif [ -f /data/adb/modules/PixelifyNext/system/product/priv-app/Velvet/Velvet.apk ]; then
            if [ $FORCE_VELVET -eq 2 ]; then
                error "- Google is not installed as a system app !!"
                log "- Making Google a system app"
                log " - Making Google a system app"
                log ""
                if [ -f $app/com.google.android.googlequicksearchbox*/base.apk ]; then
                    cp -r $app/com.google.android.googlequicksearchbox*/. $MODPATH/system/product/priv-app/Velvet
                    mv $MODPATH/system/product/priv-app/Velvet/base.apk $MODPATH/system/product/priv-app/Velvet/Velvet.apk
                else
                    cp -r data/adb/modules/Pixelify/system$product/priv-app/Velvet/. $MODPATH/system$product/priv-app/Velvet
                fi
                rm -rf $MODPATH/system/product/priv-app/Velvet/oat
            fi
            #mv $MODPATH/files/privapp-permissions-com.google.android.googlequicksearchbox.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.googlequicksearchbox.xml
        fi
}
