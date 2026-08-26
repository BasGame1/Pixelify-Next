install_dialer() {
    blue "  Do you want to enable automatic Call Screening and other dialer features?"
    blue "  Note: This feature is in BETA and you will need strong integrity and android 16"
    blue "   Vol Up += Yes"
    blue "   Vol Down += No"
    no_vk "AUTO_CALL_SCREENING"
    if $VKSEL; then               
        # Flags discovered for dialer
        echo 'resetprop -n gsm.operator.iso-country "'"$ISO,$ISO"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n gsm.sim.operator.iso-country "'"$ISO,$ISO"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n gsm.operator.numeric "'"$MCCMNC,$MCCMNC"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n gsm.sim.operator.numeric "'"$MCCMNC,$MCCMNC"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n ro.cdma.home.operator.numeric "'"$MCCMNC,$MCCMNC"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n ril.mcc.mnc0 "'"$MCCMNC,$MCCMNC"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n ril.mcc.mnc1 "'"$MCCMNC,$MCCMNC"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n persist.vendor.mtk.provision.mccmnc.0 "'"$MCCMNC,$MCCMNC"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n persist.vendor.mtk.provision.mccmnc.1 "'"$MCCMNC,$MCCMNC"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n vendor.gsm.ril.uicc.mccmnc "'"$MCCMNC,$MCCMNC"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n vendor.gsm.ril.uicc.mccmnc.1 "'"$MCCMNC,$MCCMNC"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n debug.tracing.mcc "'"$MCC"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n debug.tracing.mnc "'"$MNC"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n gsm.operator.alpha "'"$OPERATOR,$OPERATOR"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n ro.cdma.home.operator.alpha "'"$OPERATOR,$OPERATOR"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n gsm.sim.operator.alpha "'"$OPERATOR,$OPERATOR"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n ro.carrier.name "'"$OPERATOR,$OPERATOR"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n persist.sys.timezone "'"$TZ"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n gsm.operator.isroaming "false,false"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n sys.wifitracing.started "0"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n persist.vendor.wifienhancelog "0"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n ro.com.android.dataroaming "0"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n persist.vendor.radio.imei "'"$IMEI1"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n persist.vendor.radio.imei1 "'"$IMEI1"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n persist.vendor.radio.imei2 "'"$IMEI2"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n ro.serialno "'"$SERIAL_NO"'"' >>$MODPATH/post-fs-data.sh
        echo 'resetprop -n ro.boot.serialno "'"$SERIAL_NO"'"' >>$MODPATH/post-fs-data.sh
        echo 'settings put global auto_time_zone 1 2>/dev/null || true' >>$MODPATH/service.sh
        echo 'settings put global private_dns_mode off 2>/dev/null || true' >>$MODPATH/service.sh
        echo 'settings put global development_settings_enabled 1 2>/dev/null || true' >>$MODPATH/service.sh
        echo 'settings put global non_persistent_mac_randomization_force_enabled 1 2>/dev/null || true' >>$MODPATH/service.sh
        echo 'settings put global restricted_networking_mode 0 2>/dev/null || true' >>$MODPATH/service.sh
        echo 'settings put global bug_report 0 2>/dev/null || true' >>$MODPATH/service.sh
        echo 'settings put secure tethering_allow_vpn_upstreams 1 2>/dev/null || true' >>$MODPATH/service.sh

        [ -f $MODPATH/patch_microhooks.sh ] && SERVICE_BOOT=0 . $MODPATH/patch_microhooks.sh
        log " - Automatic Call Screening and Phenotype microhooks enabled"
    else
        $sqlite "$gms" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot#com.google.android.dialer'" 2>/dev/null || true
        log " - Automatic Call Screening not enabled"
    fi

    # Install language pack
    if [ -n "$lang" ]; then
        if [ -f /sdcard/Pixelify/backup/callscreen-$lang.tar.xz ]; then
            log "- Installing CallScreening $lang from backups"
            mkdir -p $MODPATH/system/product/tts/google
            tar -xf /sdcard/Pixelify/backup/callscreen-$lang.tar.xz -C $MODPATH/system/product/tts/google 2>/dev/null || true
            # install TTS Pack
            if [ -d /data/user_de/0/com.google.android.tts ] && { [ "$lang" = "hi-IN" ] || [ "$lang" = "en-IN" ]; }; then
                TTS_LOC=/data/user_de/0/com.google.android.tts/files/superpacks/$TT_LANG
                mkdir -p $TTS_LOC 2>/dev/null
                PACK_NAME="1#"
                if [ -d "$MODPATH/system/product/tts/google/$TT_LANG" ]; then
                    cd $MODPATH/system/product/tts/google/$TT_LANG
                    for i in *; do
                        [ -f "$i" ] || continue
                        j=${i/.zvoice/}
                        r="$(echo $j | tr -dc '0-9')"
                        PACK_NAME="$PACK_NAME$TT_LANG:$j;$r,"
                        mkdir -p $TTS_LOC/$j 2>/dev/null
                        unzip -q "$i" -d $TTS_LOC/$j 2>/dev/null || true
                    done
                    cd /
                    PACK_NAME=${PACK_NAME::-1}
                    SS="$("$sqlite" "/data/user_de/0/com.google.android.tts/databases/superpacks.db" "SELECT superpack_name FROM selected_packs" 2>/dev/null)"
                    if [ -z "$(echo "$SS" | grep "$TT_LANG")" ]; then
                        "$sqlite" "/data/user_de/0/com.google.android.tts/databases/superpacks.db" "INSERT INTO selected_packs(superpack_name, superpack_version, pack_list) VALUES('$TT_LANG', '$r', '$PACK_NAME')" 2>/dev/null || true
                    fi
                fi
            fi
        else
            CURL_BIN="$(get_curl_cmd)"
            CRSIZE="$("$CURL_BIN" -sI https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/callscreen-$lang.tar.xz 2>/dev/null | grep -i Content-Length | cut -d':' -f2 | sed 's/ //g' | tr -d '\r' | online_mb) Mb"
            log "  (Network Connection Needed)"
            log "  Do you want to Download Call Screening files for '$lang' language"
            log "  Size: $CRSIZE"
            log "   Vol Up += Yes"
            log "   Vol Down += No"
            no_vk "ADD_CALL_SCREENING_FILES"
            if $VKSEL; then
                online
                if [ $internet -eq 1 ]; then
                    log " - Downloading CallScreening files for '$lang'"
                    mkdir -p $MODPATH/system/product/tts/google
                    cd $MODPATH/files 2>/dev/null || true
                    [ -n "$CURL_BIN" ] && "$CURL_BIN" https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/callscreen-$lang.tar.xz -O &>/proc/self/fd/$OUTFD 2>/dev/null || true
                    cd /
                    [ -f $MODPATH/files/callscreen-$lang.tar.xz ] && tar -xf $MODPATH/files/callscreen-$lang.tar.xz -C $MODPATH/system/product/tts/google 2>/dev/null || true
                    log "  Do you want to create backup of CallScreening files for '$lang'"
                    log "   Vol Up += Yes"
                    log "   Vol Down += No"
                    no_vk "BACKUP_CALL_SCREENING_FILES"
                    if $VKSEL; then
                        log " - Creating backup for CallScreening files for '$lang'"
                        mkdir -p /sdcard/Pixelify/backup 2>/dev/null
                        [ -f $MODPATH/files/callscreen-$lang.tar.xz ] && cp -f $MODPATH/files/callscreen-$lang.tar.xz /sdcard/Pixelify/backup/callscreen-$lang.tar.xz 2>/dev/null || true
                    fi
                else
                    error " ! No internet detected"
                    log " - skipping CallScreening Resources due to no internet"
                fi
            else
                log " - skipping CallScreening Resources"
            fi
        fi
    fi

    # Remove old prompt to replace to use within overlay
    rm -rf /data/data/com.google.android.dialer/files/callrecordingprompt/* 2>/dev/null || true
    mkdir -p /data/data/com.google.android.dialer/files/callrecordingprompt 2>/dev/null
    if [ -d "$MODPATH/files/callrec" ]; then
        cp -r $MODPATH/files/callrec/* /data/data/com.google.android.dialer/files/callrecordingprompt 2>/dev/null || true
    fi

    # Make Google dialer a system app safely
    DIALER_APP_DIR="$(get_pkg_app_dir "com.google.android.dialer")"
    if [ -n "$DIALER_APP_DIR" -a -d "$DIALER_APP_DIR" ]; then
        ui_print "- Making Google Dialer a system app"
        log " - Making Google Dialer a system app from $DIALER_APP_DIR"
        mkdir -p "$MODPATH/system$product/priv-app/GoogleDialer" 2>/dev/null
        cp -r "$DIALER_APP_DIR/." "$MODPATH/system$product/priv-app/GoogleDialer" 2>/dev/null || true
        [ -f "$MODPATH/system$product/priv-app/GoogleDialer/base.apk" ] && mv "$MODPATH/system$product/priv-app/GoogleDialer/base.apk" "$MODPATH/system$product/priv-app/GoogleDialer/GoogleDialer.apk" 2>/dev/null || true
        rm -rf "$MODPATH/system$product/priv-app/GoogleDialer/oat" 2>/dev/null || true
    elif [ -f /data/adb/modules/PixelifyNext/system$product/priv-app/GoogleDialer/GoogleDialer.apk ]; then
        ui_print "- Google Dialer system app detected from existing module"
    else
        log "- Google Dialer package path not found in /data/app, skipping systemization"
    fi

    # Option to remove Samsung dialer for OneUI users
    if [ -n "$(getprop ro.oneui.version)" ] && [ $API -ge 31 ]; then 
        remove_samsung_dialer
    fi

    rm -rf $MODPATH/system$product/overlay/PixelifyGD.apk 2>/dev/null || true
    chmod 755 /data/data/com.google.android.dialer/files/phenotype 2>/dev/null || true
}
