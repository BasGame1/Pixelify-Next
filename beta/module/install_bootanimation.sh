# Pixel bootanimation
install_bootanimation() {
if [ $TARGET_DEVICE_OP12 -eq 0 ]; then
    ui_print ""
    ui_print "  Do you want to install Pixel Bootanimation?"
    ui_print "   Vol Up += Yes"
    ui_print "   Vol Down += No"
    no_vk "ENABLE_BOOTANIMATION"
    if $VKSEL; then
        ui_print " Do you want to install Gemini Bootanimation? (only AOSP)"
        ui_print "   Vol Up += Yes"
        ui_print "   Vol Down += No"
        no_vk "GEMINI_BOOTANIMATION"
        if $VKSEL; then
            ui_print " - Installing Gemini Pixel Bootanimation"
            log " - Installing Gemini Pixel Bootanimation"
            if [ -f "/system/media/bootanimation.zip" ]; then
                mkdir -p $MODPATH/system/media
                mv $MODPATH/files/gemini-bootanimation.zip $MODPATH/system/media/bootanimation.zip
                set_perm_recursive $MODPATH/system/product/media 0 0 0755 0644
            else
                if [ -f "/product/media/bootanimation.zip" ]; then
                    mkdir -p $MODPATH/system/product/media
                    mv $MODPATH/files/gemini-bootanimation.zip $MODPATH/system/product/media/bootanimation.zip
                    set_perm_recursive $MODPATH/system/product/media 0 0 0755 0644
                else
                    error " Failed to find bootanimation path"
                fi
            fi
        else
            ui_print " - Installing Pixel Bootanimation"
            log " - Installing Pixel Bootanimation"
            if [ -f /system/media/bootanimation.zip ]; then
                MEDIA_PATH=system/media
            else
                MEDIA_PATH=system/product/media
            fi
            boot_res=$(unzip -p /$MEDIA_PATH/bootanimation.zip desc.txt | head -n 1 | cut -d' ' -f1)
            if [ ! -z "$boot_res" ]; then
                green " - Detected $boot_res Resolution Bootanimation"
            else
                error " ! Failed to detect Resolution of Bootanimation"
            fi
            mkdir -p $MODPATH/$MEDIA_PATH
            if [ $MONET_BOOTANIMATION -eq 0 ]; then
                case "$boot_res" in
                720)
                    tar -xf $MODPATH/files/bootanimation-720.tar.xz -C $MODPATH/$MEDIA_PATH
                    log " - Using 720p resolution pixel Bootanimation"
                    ;;
                1440)
                    tar -xf $MODPATH/files/bootanimation-1440.tar.xz -C $MODPATH/$MEDIA_PATH
                    log " - Using 1440p resolution pixel Bootanimation"
                    ;;
                *)
                    tar -xf $MODPATH/files/bootanimation.tar.xz -C $MODPATH/$MEDIA_PATH
                    log " - Using 1080p resolution pixel Bootanimation"
                    ;;
                esac
                if [ ! -f /system/bin/themed_bootanimation ]; then
                    rm -rf $MODPATH/$MEDIA_PATH/bootanimation.zip
                    cp -f $MODPATH/$MEDIA_PATH/bootanimation-dark.zip $MODPATH/$MEDIA_PATH/bootanimation.zip
                    log " - Themed Animation not detected, using dark animation as default"
                fi
            else
                case "$boot_res" in
                720)
                    tar -xf $MODPATH/files/bootanimation-m-720.tar.xz -C $MODPATH/$MEDIA_PATH
                    log " - Using 720p resolution pixel Bootanimation"
                    ;;
                1440)
                    tar -xf $MODPATH/files/bootanimation-m-1440.tar.xz -C $MODPATH/$MEDIA_PATH
                    log " - Using 1440p resolution pixel Bootanimation"
                    ;;
                *)
                    tar -xf $MODPATH/files/bootanimation-m.tar.xz -C $MODPATH/$MEDIA_PATH
                    log " - Using 1080p resolution pixel Bootanimation"
                    ;;
                esac
                cp -f $MODPATH/$MEDIA_PATH/bootanimation.zip $MODPATH/$MEDIA_PATH/bootanimation-dark.zip
            fi
        fi
    else
        ui_print " - Skipping Pixel Bootanimation"
        log " - Skipping Pixel Bootanimation"
        rm -rf $MODPATH/system$product/media/boot*.zip 2>/dev/null
    fi
else
    ui_print " - Skipping Pixel Bootanimation"
    log " - Skipping Pixel Bootanimation"
    rm -rf $MODPATH/system$product/media/boot*.zip 2>/dev/null
fi
}
