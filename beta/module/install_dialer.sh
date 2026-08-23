install_dialer() {
 blue "  Do you want to enable automatic Call Screening and other dialer features?"
 blue "  Note: This feature is in BETA and you will need strong integrity and android 16"
 blue "   Vol Up += Yes"
 blue "   Vol Down += No"
 no_vk "AUTO_CALL_SCREENING"
 if $VKSEL; then               
                # Flags discover by @UhExooHw (gh)
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
                echo 'resetprop -n persist.vendor.radio.imei  "'"$IMEI1"'"' >>$MODPATH/post-fs-data.sh
                echo 'resetprop -n persist.vendor.radio.imei1 "'"$IMEI1"'"' >>$MODPATH/post-fs-data.sh
                echo 'resetprop -n persist.vendor.radio.imei2 "'"$IMEI2"'"' >>$MODPATH/post-fs-data.sh
                echo 'resetprop -n ro.serialno "'"$SERIAL_NO"'"' >>$MODPATH/post-fs-data.sh
                echo 'resetprop -n ro.boot.serialno "'"$SERIAL_NO"'"' >>$MODPATH/post-fs-data.sh
                settings put global auto_time_zone 1 2>/dev/null || true
                settings put global private_dns_mode off 2>/dev/null || true
                settings put global development_settings_enabled 1 2>/dev/null || true
                settings put global non_persistent_mac_randomization_force_enabled 1 2>/dev/null || true
                settings put global restricted_networking_mode 0 2>/dev/null || true
                settings put global bug_report 0 2>/dev/null || true
                settings put secure tethering_allow_vpn_upstreams 1 2>/dev/null || true

                [ -f $MODPATH/patch_microhooks.sh ] && . $MODPATH/patch_microhooks.sh
                echo " - Automatic Call Screening and Phenotype microhooks enabled" >>$logfile
            else
                $sqlite "$gms" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot#com.google.android.dialer'" 2>/dev/null || true
                echo " - Automatic Call Screening not enabled" >>$logfile
            fi

        # Install language pack
        if [ ! -z $lang ]; then
            if [ -f /sdcard/Pixelify/backup/callscreen-$lang.tar.xz ]; then
                log "- Installing CallScreening $lang from backups"
                log ""
                mkdir -p $MODPATH/system/product/tts/google
                tar -xf /sdcard/Pixelify/backup/callscreen-$lang.tar.xz -C $MODPATH/system/product/tts/google
                #install TTS Pack
                if [ -d /data/user_de/0/com.google.android.tts ] && { [ "$lang" = "hi-IN" ] || [ "$lang" = "en-IN" ]; }; then
                    TTS_LOC=/data/user_de/0/com.google.android.tts/files/superpacks/$TT_LANG
                    [ ! -d $TTS_LOC ] && mkdir -p $TTS_LOC
                    PACK_NAME="1#"
                    if [ -z "$(ls $TTS_LOC)" ]; then
                        cd $MODPATH/system/product/tts/google/$TT_LANG
                        for i in $(ls); do
                            j=${i/.zvoice/}
                            r="$(echo $j | tr -dc '0-9')"
                            PACK_NAME="$PACK_NAME$TT_LANG:$j;$r,"
                            mkdir -p $TTS_LOC/$j
                            unzip -q $i -d $TTS_LOC/$j
                        done
                        cd /
                        PACK_NAME=${PACK_NAME::-1}
                        SS="$("$sqlite" "/data/user_de/0/com.google.android.tts/databases/superpacks.db" "SELECT superpack_name FROM selected_packs")"
                        if [ -z $(echo "$SS" | grep $TT_LANG) ]; then
                            "$sqlite" "/data/user_de/0/com.google.android.tts/databases/superpacks.db" "INSERT INTO selected_packs(superpack_name, superpack_version, pack_list) VALUES('$TT_LANG', '$r', '$PACK_NAME')"
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
                        echo " - Downloading CallScreening files for '$lang'" >>$logfile
                        log "  Downloading CallScreening files for '$lang'"
                        mkdir -p $MODPATH/system/product/tts/google
                        cd $MODPATH/files
                        [ -n "$CURL_BIN" ] && "$CURL_BIN" https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/callscreen-$lang.tar.xz -O &>/proc/self/fd/$OUTFD 2>/dev/null || true
                        cd /
                        tar -xf $MODPATH/files/callscreen-$lang.tar.xz -C $MODPATH/system/product/tts/google
                        #install TTS Pack
                        if [ -d /data/user_de/0/com.google.android.tts ] && { [ "$lang" = "hi-IN" ] || [ "$lang" = "en-IN" ]; }; then
                            TTS_LOC=/data/user_de/0/com.google.android.tts/files/superpacks/$TT_LANG
                            [ ! -d $TTS_LOC ] && mkdir -p $TTS_LOC
                            PACK_NAME="1#"
                            if [ -z "$(ls $TTS_LOC)" ]; then
                                cd $MODPATH/system/product/tts/google/$TT_LANG
                                for i in $(ls); do
                                    j=${i/.zvoice/}
                                    r="$(echo $j | tr -dc '0-9')"
                                    PACK_NAME="$PACK_NAME$TT_LANG:$j;$r,"
                                    mkdir -p $TTS_LOC/$j
                                    unzip -q $i -d $TTS_LOC/$j
                                done
                                cd /
                                PACK_NAME=${PACK_NAME::-1}
                                SS="$("$sqlite" "/data/user_de/0/com.google.android.tts/databases/superpacks.db" "SELECT superpack_name FROM selected_packs")"
                                if [ -z $(echo "$SS" | grep $TT_LANG) ]; then
                                    "$sqlite" "/data/user_de/0/com.google.android.tts/databases/superpacks.db" "INSERT INTO selected_packs(superpack_name, superpack_version, pack_list) VALUES('$TT_LANG', '$r', '$PACK_NAME')"
                                fi
                            fi
                        fi
                        log ""
                        log "  Do you want to create backup of CallScreening files for '$lang'"
                        log "  so that you don't need redownload it every time."
                        log "   Vol Up += Yes"
                        log "   Vol Down += No"
                        no_vk "BACKUP_CALL_SCREENING_FILES"
                        if $VKSEL; then
                            echo " - Creating backup for CallScreening files for '$lang'" >>$logfile
                            log "- Creating Backup"
                            mkdir -p /sdcard/Pixelify/backup
                            rm -rf /sdcard/Pixelify/backup/callscreen-$lang.tar.xz
                            cp -f $MODPATH/files/callscreen-$lang.tar.xz /sdcard/Pixelify/backup/callscreen-$lang.tar.xz
                            log ""
                        fi
                    else
                        error " ! No internet detected"
                        log ""
                        log "- Skipping CallScreening Resources."
                        log ""
                        echo " - skipping CallScreening Resources due to no internet" >>$logfile
                    fi
                else
                    echo " - skipping CallScreening Resources" >>$logfile
                fi
            fi
        fi

        # Remove old prompt to replace to use within overlay
        rm -rf /data/data/com.google.android.dialer/files/callrecordingprompt/*
        mkdir -p /data/data/com.google.android.dialer/files/callrecordingprompt
        cp -r $MODPATH/files/callrec/* /data/data/com.google.android.dialer/files/callrecordingprompt

        # Updated patched com.google.android.dialer
        # mkdir -p /data/data/com.google.android.dialer/files/phenotype
        # chmod 0500 /data/data/com.google.android.dialer/files/phenotype
        # cp -Tf $MODPATH/files/$DIALER $MODPATH/$DIALER
        # chmod 0660 /data/data/com.google.android.dialer/files/phenotype/com.google.android.dialer
        # am force-stop $DIALER

        # make Google dialer as system app
        if [ -z $(pm list packages -s $DIALER) ] && [ ! -f /data/adb/modules/PixelifyNext/system/product/priv-app/GoogleDialer/GoogleDialer.apk ]; then
            print ""
            error "- Google Dialer is not installed as a system app !!"
            log "- Making Google Dialer a system app"
            echo " - Making Google Dialer a system app" >>$logfile
            print ""
            cp -r $app/com.google.android.dialer*/. $MODPATH/system$product/priv-app/GoogleDialer
            mv $MODPATH/system$product/priv-app/GoogleDialer/base.apk $MODPATH/system$product/priv-app/GoogleDialer/GoogleDialer.apk
            rm -rf $MODPATH/system$product/priv-app/GoogleDialer/oat
        # Remake google dialer as system app if Pixelify made it system app
        elif [ -f /data/adb/modules/PixelifyNext/system$product/priv-app/GoogleDialer/GoogleDialer.apk ]; then
            print ""
            error "- Google Dialer is not installed as a system app !!"
            log "- Making Google Dialer a system app"
            echo " - Making Google Dialer a system app" >>$logfile
            print ""
            cp -r $app/com.google.android.dialer*/. $MODPATH/system$product/priv-app/GoogleDialer
            mv $MODPATH/system$product/priv-app/GoogleDialer/base.apk $MODPATH/system$product/priv-app/GoogleDialer/GoogleDialer.apk
            rm -rf $MODPATH/system$product/priv-app/GoogleDialer/oat
        fi

        # Show option to remove Samsung dialer for OneUi users have android version greater than equal to Android S
        if [ ! -z "$(getprop ro.oneui.version)" ] && [ $API -ge 31 ]; then 
            remove_samsung_dialer
        else
        # Remove Google dialer files if user doesn't want to enable it
        rm -rf $MODPATH/system$product/overlay/PixelifyGD.apk
        chmod 755 /data/data/com.google.android.dialer/files/phenotype
        sed -i -e "s/cp -Tf $MODDIR\/com.google.android.dialer/#cp -Tf $MODDIR\/com.google.android.dialer/g" $MODPATH/service.sh
        sed -i -e "s/chmod 500 \/data\/data\/com.google.android.dialer\/files\/phenotype/#chmod 500 \/data\/data\/com.google.android.dialer\/files\/phenotype/g" $MODPATH/service.sh
    fi
}
