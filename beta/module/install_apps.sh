install_apps() {
if [ -d /data/data/com.google.android.googlequicksearchbox ] && [ $API -ge 29 ] && [ $TARGET_DEVICE_ONEUI -eq 0 ]; then
    blue "  Google is installed."
    log "  Do you want to installed Journal app?"
    log "   Vol Up += Yes"
    log "   Vol Down += No"
    no_vk "INSTALL_JOURNAL"
    if $VKSEL; then
        log " - Installing Google Journal"
        log "- Installing Google Journal"
        log ""
        install_apk "Journal.apk" "$MODPATH/files/Journal.apk"
     fi
fi

if [ -d /data/data/com.google.android.googlequicksearchbox ] && [ $API -ge 36 ]; then
    log "  Google is installed."
    log "  Do you want to installed Now Playing?"
    log "  (needs aicore and device intelligence)"
    log "   Vol Up += Yes"
    log "   Vol Down += No"
    no_vk "QUICK_SHARE"
    if $VKSEL; then
        log " - Installing Now Playing " >>$logfile
        log "- Installing Now Playing "
        log ""
        install_apk "nowplaying.apkm" "$MODPATH/files/nowplaying.apkm" "arm64"
     fi
fi
}
