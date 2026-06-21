install_wallpapers() {
if [ $API -ge 28 ]; then
    PLW=$(find /system -name *PixelWallpapers2021* | grep -v overlay | grep -v "\.")
    PLW1=$(find /system -name *WallpapersBreel2* | grep -v overlay | grep -v "\.")
    if [ -f /sdcard/Pixelify/backup/pixel.tar.xz ]; then
        echo " - Backup Detected for Pixel Wallpapers" >>$logfile
        log "  Do you want to install Pixel Live Wallpapers?"
        log "  (Backup detected, no internet needed)"
        log "   Vol Up += Yes"
        log "   Vol Down += No"
        no_vk "ENABLE_LIVE_WALLPAPERS"
        if $VKSEL; then
            sed -i -e "s/Live=0/Live=1/g" $MODPATH/var.prop
            if [ "$(cat /sdcard/Pixelify/version/pixel.txt)" != "$LWVERSION" ]; then
                echo " - New Version Backup Detected for Pixel Wallpapers" >>$logfile
                echo " - Old version:$(cat /sdcard/Pixelify/version/pixel.txt), New Version:  $LWVERSION " >>$logfile
                log "  (Network Connection Needed)"
                log "  New version Detected "
                log "  Do you Want to update or use Old Backup?"
                log "  Version: $LWVERSION"
                log "  Size: $LWSIZE"
                log "   Vol Up += Update"
                log "   Vol Down += Use old backup"
                no_vk "DOWNLOAD_LIVE_WALLPAPERS"
                if $VKSEL; then
                    online
                    if [ $internet -eq 1 ]; then
                        echo " - Downloading and Installing New Backup for Pixel Wallpapers" >>$logfile
                        rm -rf /sdcard/Pixelify/backup/pixel.tar.xz
                        rm -rf /sdcard/Pixelify/version/pixel.txt
                        cd $MODPATH/files
                        if [ $API -ge 31 ]; then
                            $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pixel.tar.xz -O &>/proc/self/fd/$OUTFD
                        else
                            $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pixel-old.tar.xz -O &>/proc/self/fd/$OUTFD
                            mv pixel-old.tar.xz pixel.tar.xz
                        fi
                        cd /
                        log "- Creating Backup"
                        log ""
                        cp -f $MODPATH/files/pixel.tar.xz /sdcard/Pixelify/backup/pixel.tar.xz
                        echo " - Creating Backup for Pixel Wallpapers" >>$logfile
                        echo "$LWVERSION" >>/sdcard/Pixelify/version/pixel.txt
                    else
                        error " ! No internet detected"
                        log ""
                        log " ! Using Old backup for now."
                        log ""
                        echo " ! Using old Backup for Pixel Wallpapers due to no internet" >>$logfile
                    fi
                fi
            fi
            log "- Installing Pixel LiveWallpapers"
            log ""
            tar -xf /sdcard/Pixelify/backup/pixel.tar.xz -C $MODPATH/system$product
            pm install $MODPATH/system$product/priv-app/PixelLiveWallpaperPrebuilt/*.apk &>/dev/null

            if [ $API -le 28 ]; then
                mv $MODPATH/system/overlay/Breel*.apk $MODPATH/vendor/overlay
                rm -rf $MODPATH/system/overlay
            fi
            REMOVE="$REMOVE $PLW $PLW1"
            pm enable -n com.google.pixel.livewallpaper/com.google.pixel.livewallpaper.pokemon.wallpapers.PokemonWallpaper -a android.intent.action.MAIN &>/dev/null
            mkdir -p $MODPATH/system$product/app/WallpapersBReel2020/lib/arm64
            cp -f $MODPATH/system$product/lib64/libgdx.so $MODPATH/system$product/app/WallpapersBReel2020/lib/arm64/libgdx.so
            install_wallpaper_with_backup
            WALL_DID=1
        else
            echo " - Using old backup Pixel Wallpapers" >>$logfile
        fi
    else
        log "  (Network Connection Needed)"
        log "  Do you want to install and Download Pixel LiveWallpapers?"
        log "  Size: $LWSIZE"
        log "   Vol Up += Yes"
        log "   Vol Down += No"
        no_vk "ENABLE_LIVE_WALLPAPERS"
        if $VKSEL; then
            online
            if [ $internet -eq 1 ]; then
                sed -i -e "s/Live=0/Live=1/g" $MODPATH/var.prop
                log "- Downloading Pixel LiveWallpapers"
                echo " - Downloading and Installing Pixel Wallpapers" >>$logfile
                log ""
                cd $MODPATH/files
                if [ $API -ge 31 ]; then
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pixel.tar.xz -O &>/proc/self/fd/$OUTFD
                else
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/pixel-old.tar.xz -O &>/proc/self/fd/$OUTFD
                    mv pixel-old.tar.xz pixel.tar.xz
                fi
                cd /
                log ""
                log "- Installing Pixel Live Wallpapers"
                tar -xf $MODPATH/files/pixel.tar.xz -C $MODPATH/system$product
                pm install $MODPATH/system$product/priv-app/PixelLiveWallpaperPrebuilt/*.apk &>/dev/null

                if [ $API -le 28 ]; then
                    mv $MODPATH/system/overlay/Breel*.apk $MODPATH/vendor/overlay
                    rm -rf $MODPATH/system/overlay
                fi
                log ""
                log "  Do you want to create backup of Pixel LiveWallpapers?"
                log "  so that you don't need redownload it every time."
                log "   Vol Up += Yes"
                log "   Vol Down += No"
                no_vk "BACKUP_LIVE_WALLPAPERS"
                if $VKSEL; then
                    log "- Creating Backup"
                    mkdir -p /sdcard/Pixelify/backup
                    rm -rf /sdcard/Pixelify/backup/pixel.tar.xz
                    cp -f $MODPATH/files/pixel.tar.xz /sdcard/Pixelify/backup/pixel.tar.xz
                    log ""
                    mkdir /sdcard/Pixelify/version
                    echo " - Creating Backup for Pixel Wallpapers" >>$logfile
                    echo "$LWVERSION" >>/sdcard/Pixelify/version/pixel.txt
                    green " - Done"
                    print ""
                fi
                REMOVE="$REMOVE $PLW $PLW1"
                pm enable -n com.google.pixel.livewallpaper/com.google.pixel.livewallpaper.pokemon.wallpapers.PokemonWallpaper -a android.intent.action.MAIN &>/dev/null
                mkdir -p $MODPATH/system$product/app/WallpapersBReel2020/lib/arm64
                cp -f $MODPATH/system$product/lib64/libgdx.so $MODPATH/system$product/app/WallpapersBReel2020/lib/arm64/libgdx.so
                install_wallpaper_with_backup
                WALL_DID=1
            else
                error " ! No internet detected"
                print ""
                error " ! Skipping Pixel LiveWallpaper"
                print ""
                echo " ! Skipping Pixel Wallpapers due to no internet" >>$logfile
            fi
        else
            echo " - Skipping Pixel Wallpapers" >>$logfile
        fi
    fi
fi
}
