install_nga() {
if [ -d /data/data/com.google.android.googlequicksearchbox ] && [ $API -ge 29 ] && [ $TARGET_DEVICE_ONEUI -eq 0 ]; then
    log "  Google is installed."
    log "  Do you want to install Next generation assistant?"
    log "   Vol Up += Yes"
    log "   Vol Down += No"
    no_vk "ENABLE_NGA"
    if $VKSEL; then
        log " - Installing Next generation assistant"
        # Check backup is present ot not, older Pixelify uses NgaResources.apk and new ones nga.tar.xz
        if [ -f /sdcard/Pixelify/backup/nga.tar.xz ] || [ -f /sdcard/Pixelify/backup/NgaResources.apk ]; then

            # Check backup is upto date
            if [ "$(cat /sdcard/Pixelify/version/nga.txt)" != "$NGAVERSION" ]; then
                log " - New Version Detected for NGA Resources"
                log " - Installed version: $(cat /sdcard/Pixelify/version/nga.txt) , New Version: $NGAVERSION "
                log "  (Network Connection Needed)"
                log "  New version Detected."
                log "  Do you Want to update or use Old Backup?"
                log "  Version: $NGAVERSION"
                log "  Size: $NGASIZE"
                log "   Vol Up += Update"
                log "   Vol Down += Use old backup"
                no_vk "UPDATE_NGA_RES"
                if $VKSEL; then
                    # check internet is avail or not
                    online
                    if [ $internet -eq 1 ]; then
                        log " - Downloading, Installing and creating backup NGA Resources"
                        rm -rf /sdcard/Pixelify/backup/NgaResources.apk
                        rm -rf /sdcard/Pixelify/backup/nga.tar.xz
                        rm -rf /sdcard/Pixelify/version/nga.txt
                        cd $MODPATH/files
                        # Download version according to variables
                        # OSR with Offline Speech Recogonition 50xx
                        # DOES_NOT_REQ_SPEECH_PACK to forcelly disable with speechpack one only NGA Resources
                        if [ $ENABLE_OSR -eq 1 ] || [ $DOES_NOT_REQ_SPEECH_PACK -eq 1 ]; then
                            if [ $API -eq 30 ] || [ $API -eq 33 ]; then
                                $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/nga-new-$API.tar.xz -o nga.tar.xz &>/proc/self/fd/$OUTFD
                            else
                                $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/nga-new-31.tar.xz -o nga.tar.xz &>/proc/self/fd/$OUTFD
                            fi
                        else
                            $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/nga.tar.xz -o nga.tar.xz &>/proc/self/fd/$OUTFD
                        fi
                        cd /
                        # Create backup
                        log ""
                        log "- Creating Backup"
                        log ""
                        cp -Tf $MODPATH/files/nga.tar.xz /sdcard/Pixelify/backup/nga.tar.xz
                        echo "$NGAVERSION" >>/sdcard/Pixelify/version/nga.txt
                    else
                        # No internet dected
                        error " ! No internet detected"
                        log ""
                        log " ! Using Old backup for now."
                        log ""
                        log " ! using old backup for NGA Resources due to no internet"
                    fi
                else
                    log " - using old backup for NGA Resources"
                fi
            fi
            log "- Installing NgaResources from backups"
            log ""
            # Extract nga.tar.xz
            tar -xf /sdcard/Pixelify/backup/nga.tar.xz -C $MODPATH/system/product
        else
            log "  (Network Connection Needed)"
            log "  Do you want to install and Download NGA Resources"
            log "  Size: $NGASIZE"
            log "   Vol Up += Yes"
            log "   Vol Down += No"
            no_vk "DOWNLOAD_NGA_RES"
            if $VKSEL; then
                online
                if [ $internet -eq 1 ]; then
                    log " - Downloading and Installing NGA Resources"
                    log " - Downloading NGA Resources"
                    cd $MODPATH/files
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/nga-new.tar.xz -o nga.tar.xz -O &>/proc/self/fd/$OUTFD
                    cd /
                    tar -xf $MODPATH/files/nga.tar.xz -C $MODPATH/system/product
                    log ""
                    log "  Do you want to create backup of NGA Resources"
                    log "  so that you don't need redownload it every time."
                    log "   Vol Up += Yes"
                    log "   Vol Down += No"
                    no_vk "BACKUP_NGA"
                    if $VKSEL; then
                        log " - Creating backup for NGA Resources"
                        log "- Creating Backup"
                        mkdir -p /sdcard/Pixelify/backup
                        rm -rf /sdcard/Pixelify/backup/NgaResources.apk
                        rm -rf /sdcard/Pixelify/backup/nga.tar.xz
                        cp -f $MODPATH/files/nga.tar.xz /sdcard/Pixelify/backup/nga.tar.xz
                        mkdir -p /sdcard/Pixelify/version
                        echo "$NGAVERSION" >>/sdcard/Pixelify/version/nga.txt
                        log ""
                        log "- NGA Resources installation complete"
                        log ""
                    fi
                else
                    error " ! No internet detected"
                    log ""
                    log "- Skipping NGA Resources."
                    log ""
                    log " - skipping NGA Resources due to no internet"
                fi
            else
                log " - skipping NGA Resources"
            fi
        fi

        # copy NGA files
        cp -f $MODPATH/files/nga.xml $MODPATH/system$product/etc/sysconfig/nga.xml
        cp -f $MODPATH/files/PixelifyGA.apk $MODPATH/system/product/overlay/PixelifyGA.apk
        # ok_google_hotword
        if [ $ENABLE_OSR -eq 1 ]; then
            osr_ins
        fi

        # Option to make Google app as system app or not forcely
        # in /sdcard/Pixelify/apps.txt add velet=1
        if [ -f $FORCE_FILE ]; then
            is_velvet="$(grep velvet= $FORCE_FILE | cut -d= -f2)"
            if [ $is_velvet -eq 1 ]; then
                FORCE_VELVET=1
            elif [ $is_velvet -eq 0 ]; then
                FORCE_VELVET=0
            else
                FORCE_VELVET=2
            fi
        else
            FORCE_VELVET=2
        fi
# Make Google app as system app
        if [ -z $(pm list packages -s com.google.android.googlequicksearchbox | grep -v nga) ] && [ ! -f /data/adb/modules/PixelifyNext/system/product/priv-app/Velvet/Velvet.apk ] || [ $FORCE_VELVET -eq 1 ]; then
            VELVET_DIR="$(get_pkg_app_dir "com.google.android.googlequicksearchbox")"
            if [ -n "$VELVET_DIR" -a -d "$VELVET_DIR" ]; then
                ui_print "- Making Google a system app"
                log " - Making Google a system app"
                mkdir -p $MODPATH/system/product/priv-app/Velvet 2>/dev/null
                cp -r "$VELVET_DIR/." $MODPATH/system/product/priv-app/Velvet 2>/dev/null || true
                [ -f $MODPATH/system/product/priv-app/Velvet/base.apk ] && mv $MODPATH/system/product/priv-app/Velvet/base.apk $MODPATH/system/product/priv-app/Velvet/Velvet.apk 2>/dev/null || true
                rm -rf $MODPATH/system/product/priv-app/Velvet/oat 2>/dev/null || true
            fi
        elif [ -f /data/adb/modules/PixelifyNext/system/product/priv-app/Velvet/Velvet.apk ]; then
            VELVET_DIR="$(get_pkg_app_dir "com.google.android.googlequicksearchbox")"
            if [ -n "$VELVET_DIR" -a -d "$VELVET_DIR" ]; then
                ui_print "- Making Google a system app"
                log " - Making Google a system app"
                mkdir -p $MODPATH/system/product/priv-app/Velvet 2>/dev/null
                cp -r "$VELVET_DIR/." $MODPATH/system/product/priv-app/Velvet 2>/dev/null || true
                [ -f $MODPATH/system/product/priv-app/Velvet/base.apk ] && mv $MODPATH/system/product/priv-app/Velvet/base.apk $MODPATH/system/product/priv-app/Velvet/Velvet.apk 2>/dev/null || true
                rm -rf $MODPATH/system/product/priv-app/Velvet/oat 2>/dev/null || true
            fi
        fi
    else
        NO_NGA=true
    fi
fi
}
