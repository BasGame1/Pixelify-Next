#!/system/bin/sh
ui_print " ____  _ ___  _ _____ _     _  ________  _";
ui_print "/  __\\/ \\\\  \\///  __// \\   / \\/    /\\  \\//";
ui_print "|  \\/|| | \\  / |  \\  | |   | ||  __\\ \\  / ";
ui_print "|  __/| | /  \\ |  /_ | |_/\\| || |    / /  ";
ui_print "\\_/   \\_//__/\\\\\\____\\\\____/\\_/\\_/   /_/   ";
ui_print "                                          ";
ui_print " _      ________  _ _____                 ";
ui_print "/ \\  /|/  __/\\  \\///__ __\\                ";
ui_print "| |\\ |||  \\   \\  /   / \\                  ";
ui_print "| | \\|||  /_  /  \\   | |                  ";
ui_print "\\_/  \\|\\____\\/__/\\\\  \\_/                  ";
ui_print "                                          ";
ui_print "                                          ";
ui_print "                                          ";
# extract module files to MODPATH
unzip -o "$ZIPFILE" -d "$MODPATH" >&2

# run Pixelify Functions and Variables
. $MODPATH/terminal.sh || abort "terminal script not loaded"
. $MODPATH/vars.sh || abort "vars script not loaded"
. $MODPATH/utils.sh || abort "utils script not loaded"
. $MODPATH/functions.sh || abort "functions script not loaded"
. $MODPATH/install_apk.sh || abort "apk installer script not loaded"
. $MODPATH/install_wallpapers.sh || abort "Wallpapers script not loaded"
. $MODPATH/install_launcher.sh || abort "Launcher script not loaded"
. $MODPATH/install_bootanimation.sh || abort "Bootanimation script not loaded"
. $MODPATH/install_dialer.sh || abort "dialer script not loaded"
. $MODPATH/install_nga.sh || abort "nga script not loaded"
. $MODPATH/install_apps.sh || abort "apps script not loaded"
. $MODPATH/systemize_velvet.sh || abort "systemize velvet script not loaded"

chmod 0755 $MODPATH/addon/* $MODPATH/*.sh 2>/dev/null

alias keycheck="$MODPATH/addon/keycheck"
sqlite=$MODPATH/addon/sqlite3
VOL_KEYS="$(grep 'DEVICE_USES_VOLUME_KEY=' $MODPATH/module.prop | cut -d= -f2)"
MAGISK_CLI="$(which magisk)"
chmod 0755 $sqlite

[ -z "$MAGISKTMP" ] && MAGISKTMP=/sbin

# Fetch Zygisk is enabled or not from magisk database
zygisk_enabled="$(magisk --sqlite "SELECT value FROM settings WHERE (key='zygisk')")"

# Update Riru Path
if [ "$MAGISK_VER_CODE" -ge 21000 ]; then
    MAGISK_CURRENT_RIRU_MODULE_PATH=$(magisk --path)/.magisk/modules/riru-core
else
    MAGISK_CURRENT_RIRU_MODULE_PATH=/sbin/.magisk/modules/riru-core
fi

# Set Riru util_functions path
if [ -f $MAGISK_CURRENT_RIRU_MODULE_PATH/util_functions.sh ]; then
    riru_path=$MAGISK_CURRENT_RIRU_MODULE_PATH/util_functions.sh
elif [ -f /data/adb/riru/util_functions.sh ]; then
    riru_path=$MAGISK_CURRENT_RIRU_MODULE_PATH/util_functions.sh
else
    riru_path=""
fi
# Set Installation type: Normal, Zygsik, Riru
if [ "$KSU" == true ]; then
    log "- Root App: KSU"
    if [ -d '/data/adb/modules/rezygisk' ]; then
        # Rezygisk is installed.
        # Set the module type to Rezygisk
        MODULE_TYPE=2
        log "- Installation Type: Rezygisk"
    elif [ -d '/data/adb/modules/zygisksu' ]; then
    	# ZygsikNext is installed.
        # Set the module type to ZygiskNext
        MODULE_TYPE=2
        log "- Installation Type: ZygiskNext"
    else
        # Rezygisk or zygisk next is not installed.
        # Set the module type to normal installation
        MODULE_TYPE=1
        log "- Installation Type: normal installation"
    fi
elif [ ! -z  "$MAGISK_CLI" ]; then 
    log "- Root App: Magisk"
    if [ ! -z $riru_path ]; then
        # Riru is installed.
        # Check if Zygisk is enabled.
        if [ "$zygisk_enabled" == "value=1" ]; then
            # Set the module type to Zygsik
            MODULE_TYPE=2
            log "! Riru Installed but disabled"
            log "- Switching to zygisk mode"
            log ""
            log "- Installation Type: Zygisk"
        else
            # Riru is disabled.
            log "- Load $MAGISK_CURRENT_RIRU_MODULE_PATH/util_functions.sh"
            # Load the Riru utility functions.
            . $riru_path
            # Check the installation type.
            check_install_type
        fi
    else
        # Riru is not installed.
        # Check if Magisk is at least version 24000.
        if [ "$MAGISK_VER_CODE" -ge 24000 ]; then
            # Magisk is at least version 24000.
            # Set the module type to 2.
            MODULE_TYPE=2
            log "- Installation Type: Zygisk"
            # Check if zygsik is enabled.
            if [ "$zygisk_enabled" != "value=1" ]; then
                # Riru is not enabled.
                log "! Please enable zygisk in magisk"
            fi
        else
            # Magisk is not at least version 24000.
            # Set the module type normal installation
            MODULE_TYPE=1
            log "- Installation Type: normal installation"
        fi
    fi
else 
    # Apatch or an unkown root app is installed.
    # Set the module type to normal installation
    log "- Root App: Apatch or unknown"
    if [ -d '/data/adb/modules/rezygisk' ]; then
        # Rezygisk is installed.
        # Set the module type to Rezygisk
        MODULE_TYPE=2
        blue "- Installation Type: Rezygisk"
    elif [ -d '/data/adb/modules/zygisksu' ]; then
    	# ZygsikNext is installed.
        # Set the module type to ZygiskNext
        MODULE_TYPE=2
        blue "- Installation Type: ZygiskNext"
    else
        # Rezygisk or zygisk next is not installed.
        # Set the module type to normal installation
        MODULE_TYPE=1
        blue "- Installation Type: normal installation"
    fi
fi

# Update Library according to installation type
if [ $MODULE_TYPE -eq 2 ]; then
    # The module is using Zygisk.
    # Move the Zygisk libraries to the `zygisk` directory in the module path.
    mv "$ZYGISK_LIB_PATH" "$MODPATH/zygisk"
 # Delete other arch libraries
    if [ $ARCH = arm64 ] || [ $ARCH = aarch64 ]; then
        for FILE in $MODPATH/zygisk/armeabi-v7a.so $MODPATH/zygisk/libpixelify-next-camera-32.so $MODPATH/zygisk/libpixelify-next-photos-32.so $MODPATH/zygisk-tensor/armeabi-v7a.so; do
            rm -rf $FILE
        done
    elif [ $ARCH = armeabi ] || [ $ARCH = armeabi-v7a ] || [ $ARCH = arm32 	]; then
        for FILE in $MODPATH/zygisk/arm64-v8a.so $MODPATH/zygisk/libpixelify-next-camera-64.so $MODPATH/zygisk/libpixelify-next-photos-64.so $MODPATH/zygisk-tensor/arm64-v8a.so; do
            rm -rf $FILE
        done
    else
        error " x Unsupported zygisk platform: $ARCH." 
        error " x Spoofing and other features wont work."
    fi
fi

# Exit for Unsupported Android Versions (Required Nougat+)
if [ $API -le 23 ]; then
    error " x Minimum requirements doesn't meet"
    error " x Android version: 7.0+"
    exit 1
fi

#sql file
touch $MODPATH/flags.txt

# Check architecture
if [ "$ARCH" != "arm" ] && [ "$ARCH" != "arm64" ] && [ "$ARCH" != "x86" ] && [ "$ARCH" != "x64" ]; then
    abort " x Unsupported platform: $ARCH"
fi

# Check for internal spoofing is available when ro.xxx.device disables it.
for i in $overide_spoof; do
    if [ ! -z $i ]; then
        kkk="$(getprop $i)"
        if [ ! -z $kkk ] || [ "$kkk" == "redfin" ]; then
            exact_prop="$i"
            spoof_message="  Note: This may break ota update of your rom"
            KEEP_PIXEL_2021=1
            break
        fi
    fi
done

# Check for internal spoofing is available when it is detected with ro.xxx.device but ro.product.device disables it.
if [ -z $exact_prop ]; then
    for i in $device_spoof; do
        if [ ! -z $i ]; then
            kkk="$(getprop $i)"
            if [ ! -z $kkk ] || [ "$kkk" == "redfin" ]; then
                exact_prop="ro.product.device"
                spoof_message="  Note: This may cause issue to Google camera"
                KEEP_PIXEL_2021=1
                break
            fi
        fi
    done
fi

# Check for internal spoofing is available when it is detected with ro.xxx.device but org.pixelexperience.device disables it.
if [ -z $exact_prop ]; then
    for i in $pixel_spoof; do
        if [ ! -z $i ]; then
            kkk="$(getprop $i)"
            if [ ! -z $kkk ] || [ "$kkk" == "redfin" ]; then
                exact_prop="org.pixelexperience.device"
                break
            fi
        fi
    done
fi

# Roms which have Unlimited photos Featues, so that we could copy PIXEL_2021 without breaking Unilimited backup
if [ $KEEP_PIXEL_2021 -eq 0 ] && [ $API -eq 33 ]; then
    for i in $PIXEL_2021_ROMS; do
        if [ ! -z $i ]; then
            kkk="$(getprop $i)"
            if [ ! -z $kkk ]; then
                KEEP_PIXEL_2021=1
                break
            fi
        fi
    done
    if [ $KEEP_PIXEL_2021 -eq 0 ] && [ ! -z "$(getprop ro.custom.version | grep PixelOS)" ]; then
        KEEP_PIXEL_2021=1
    fi
fi

# if [ -z $exact_prop ]; then
#     case "$(getprop ro.custom.version)" in
#     PixelOS_*)
#         exact_prop="ro.custom.device"
#         ;;
#     esac
# fi

# Clean up old logs
rm -rf $logfile
rm -rf $flaglogfile

am force-stop com.android.vending

# Logs initial format
echo "=============
   Pixelify $(cat $MODPATH/module.prop | grep version= | cut -d= -f2)
   SDK version: $API
=============
---- Installation Logs Started ----
" >>$logfile

# set permissions to executables
chmod 0755 $MODPATH/addon/*

# Check phones is a ONEPLUS device and requires crash fix
if [ -d /system_ext/oplus ] && [ $ROMTYPE == "oplus" ]; then
    REQ_FIX=1
fi

# Set variables indicating fixes for ROMS
if [ $API -ge 31 ] && [ $REQ_FIX -eq 1 ]; then
    TARGET_DEVICE_OP12=1
elif [ $API -ge 31 ] && [ $ROMTYPE == "oneui" ]; then
    TARGET_DEVICE_ONEUI=1
fi

# Fix for Pixel Launcher in Oneplus devices
if [ $TARGET_DEVICE_OP12 -eq 1 ] && [ $API -eq 33 ]; then
    LOS_FIX=1
fi

# Check internet is present of not
online
if [ $internet -eq 1 ]; then
    green "- Internet: Present"
else
    error "- Internet: Not Present"
fi

#Create Pixelify directory for saving backups and logs.
mkdir -p /sdcard/Pixelify

# create Pixelify data directory (It saves which options are choosen)
if [ ! -d $pix ]; then
    mkdir -p $pix
fi

# We start apps selection in apps_temp.txt (Fixes bug when installation failed so updated in the end to app.txt)
if [ -f $pix/app.txt ]; then
    rm -rf $pix/apps_temp.txt
    cp -f $pix/app.txt $pix/apps_temp.txt
0;276;0c0;276;0c0;276;0celse
    touch $pix/apps_temp.txt
fi

rm -rf $pix/app2.txt
touch $pix/app2.txt

# Set default Nga resources version
if [ $ENABLE_OSR -eq 1 ] || [ $DOES_NOT_REQ_SPEECH_PACK -eq 1 ]; then
    NGAVERSIONP=1.3
fi

# Fetch Security patch and Build Date of ROM
sec_patch=$(date -d $(getprop ro.build.version.security_patch) +%s)
build_date=$(getprop ro.build.date.utc)

# USE Recents fix Pixel Launcher for Android 13
if [ $API -eq 33 ]; then
    LOS_FIX=1
fi

# Set Does Pixel Launcher Requires new Package
if [ $API -eq 31 ]; then
    # Check if the security patch is greater than or equal to December 2021
    if [ $sec_patch -ge $(date -d 2021-12-01 +%s) ]; then
        PL_VERSION="dec_2021"
    fi
elif [ $API -eq 32 ]; then
    if [ $sec_patch -ge $(date -d 2022-06-01 +%s) ] || [ $build_date -ge $(date -d 2022-06-01 +%s) ]; then
        PL_VERSION="jun_2022"
    fi
elif [ $API -eq 33 ]; then
    if [ $sec_patch -ge $(date -d 2023-08-01 +%s) ] || [ $build_date -ge $(date -d 2023-08-01 +%s) ]; then
        PL_VERSION="aug_2023"
        LOS_FIX=0
    elif [ $sec_patch -ge $(date -d 2023-07-01 +%s) ] || [ $build_date -ge $(date -d 2023-07-01 +%s) ]; then
        PL_VERSION="jul_2023"
        LOS_FIX=0
    elif [ $sec_patch -ge $(date -d 2023-05-01 +%s) ] || [ $build_date -ge $(date -d 2023-05-01 +%s) ]; then
        PL_VERSION="may_2023"
    elif [ $sec_patch -ge $(date -d 2022-12-01 +%s) ] || [ $build_date -ge $(date -d 2022-12-01 +%s) ]; then
        PL_VERSION="dec_2022"
    fi
    if [ $sec_patch -ge $(date -d 2023-06-01 +%s) ] || [ $build_date -ge $(date -d 2023-06-01 +%s) ]; then
        REQ_NEW_WLP=1
    fi
fi

if [ $LOS_FIX -eq 1 ]; then
    PL_VERSION="los_$PL_VERSION"
fi

echo "- Pixel Launcher version required for sdk $API: $PL_VERSION" >>$logfile

#save device info in logs
echo "
- Device info -
Codename: $(getprop ro.product.vendor.name)
Model: $(getprop ro.product.vendor.model)
security patch: $sec_patch
Magisk version: $MAGISK_VER_CODE
 - Device info -
" >>$logfile

# Set version and size when Pixelify is launcher (used when device doesn't use internet)
if [ $API -eq 34 ]; then
    echo "Android version: 14" >>$logfile
    WNEED=1
    DPSIZE="33 Mb"
    WSIZE="6 Mb"
    PLSIZE="11 Mb"
    DPVERSIONP=1
    PLVERSIONP=1
elif [ $API -eq 33 ]; then
    echo "Android version: 13" >>$logfile
    WNEED=1
    DPSIZE="35 Mb"
    WSIZE="2.2 Mb"
    PLSIZE="11 Mb"
    DPVERSIONP=3.6
    PLVERSIONP=1
elif [ $API -eq 32 ]; then
    echo "Android version: 12.1 (12L)" >>$logfile
    WNEED=1
    DPSIZE="52 Mb"
    WSIZE="2.2 Mb"
    PLSIZE="11 Mb"
    DPVERSIONP=2.7
    if [ $NEW_PL -eq 1 ]; then
        PLVERSIONP=2.1
    else
        PLVERSIONP=1.3
    fi
    PLSIZE="11 Mb"
elif [ $API -eq 31 ]; then
    echo "Android version: 12 (S)" >>$logfile
    DPSIZE="52 Mb"
    DPVERSIONP=2.5
    WSIZE="2.0 Mb"
    WNEED=1
    if [ $NEW_JN_PL -eq 1 ]; then
        PLVERSIONP=1.4
    elif [ $NEW_PL -eq 1 ]; then
        PLVERSIONP=1.4
    else
        PLVERSIONP=1.3
    fi
    PLSIZE="11 Mb"
elif [ $API -eq 30 ]; then
    echo "Android version: 11 (R)" >>$logfile
    DPSIZE="20 Mb"
    DPVERSIONP=1.2
    WSIZE="2.1 Mb"
    WNEED=1
elif [ $API -eq 29 ]; then
    echo "Android version: 10 (Q)" >>$logfile
    WSIZE="3.6 Mb"
    DPSIZE="15 Mb"
    DPVERSIONP=1
    WNEED=1
elif [ $API -eq 28 ]; then
    echo "Android version: 9 (Pie)" >>$logfile
    WSIZE="1.6 Mb"
    DPSIZE="10 Mb"
    DPVERSIONP=1
    WNEED=1
fi
WLPVERSIONP=1
WLPSIZE="3 Mb"

# Fetch latest version
fetch_version

# Finally set version of offline package
set_version

# Fixes for Pixel 4 devices, it gets hang when Android System intelligence gets spoofed to another pixel
if [ "$(getprop ro.product.vendor.name)" == "coral" ] || [ "$(getprop ro.product.vendor.name)" == "flame" ]; then
    echo "- Pixel 4/XL Detected !" >>$logfile
    for i in $MODPATH/zygisk/* $MODPATH/riru/*/*; do
        sed -i -e "s/com.google.android.xx/com.google.android.as/g" $i
    done
fi

# Save version fetched in logs
echo "
- NGA version: $NGAVERSION
- Pixel Live Wallpapers version: $NGAVERSION
- Device Personalisation Services version: $DPVERSION
- Pixel Launcher ($API) version: $PLVERSION
" >>$logfile

# Set permisions
chmod -R 0755 $MODPATH/addon
chmod 0644 $MODPATH/files/*.xz

# Find the all accounts signed in Device
gacc="$("$sqlite" "$gms" "SELECT DISTINCT(user) FROM Flags WHERE user != '';")"

# Android lower than Q doesn't properly use product or system_ext partion, move it to system
if [ $API -le 28 ]; then
    cp -r $MODPATH/system/product/. $MODPATH/system
    cp -r $MODPATH/system/overlay/. $MODPATH/system/vendor/overlay
    cp -r $MODPATH/system/system_ext/. $MODPATH/system
    rm -rf $MODPATH/system/overlay
    rm -rf $MODPATH/system/product
    rm -rf $MODPATH/system/system_ext
    product=
else
    product=/product
fi

# create priv-app, app folders to copy in future
mkdir -p $MODPATH/system$product/priv-app
mkdir -p $MODPATH/system$product/app

# print basic device info
blue ""
blue "- Detected Arch: $ARCH"
blue "- Detected SDK : $API"
RAM=$(grep MemTotal /proc/meminfo | tr -dc '0-9')
blue "- Detected Ram: $RAM"
check_rom_type

LINEAGE_VER="$(getprop ro.lineage.version 2>/dev/null)"
LINEAGE_BUILD="$(getprop ro.lineage.build.version 2>/dev/null)"
MOD_VER="$(getprop ro.modversion 2>/dev/null)"
if echo "$LINEAGE_VER $LINEAGE_BUILD $MOD_VER" | grep -q "23.2"; then
    error "=================================================="
    error " WARNING: LineageOS 23.2 Detected!"
    error " This version may contain bugs or bootloops."
    error " Proceed with caution!"
    error "=================================================="
    echo "- LineageOS 23.2 warning displayed" >> $logfile
    sleep 3
fi
blue ""

# remove pinning of Google camera, as it is not recommended to use for device less than 6gb ram
if [ $RAM -le "6000000" ]; then
    rm -rf $MODPATH/system$product/etc/sysconfig/GoogleCamera_6gb_or_more_ram.xml
    echo " - Removing GoogleCamera_6gb_or_more_ram.xml as device has less than 6Gb Ram" >>$logfile
fi

DIALER1=$(find /system -name *Dialer.apk)
GOOGLE=$(find /system -name Velvet.apk)

# Remove Android System Intelligence app if installed
if [ $API -ge "28" ]; then
    if [ ! -z $(find /system -name DevicePerson* | grep -v "\.") ] && [ ! -z $(find /system -name DevicePerson* | grep -v "\.") ]; then
        DP1=$(find /system -name DevicePerson* | grep -v "\.")
        DP2=$(find /system -name Matchmaker* | grep -v "\.")
        DP="$DP1 $DP2"
    elif [ -z $(find /system -name DevicePerson* | grep -v "\.") ]; then
        DP=$(find /system -name Matchmaker* | grep -v "\.")
    else
        DP=$(find /system -name DevicePerson* | grep -v "\.")
    fi
fi

# Remove Google Health services
if [ $API -ge 28 ]; then
    TUR=$(find /system -name Turbo*.apk | grep -v overlay)
    REMOVE="$REMOVE $TUR"
fi

# set Config.prop location
if [ -f /sdcard/Pixelify/config.prop ]; then
    vk_loc="/sdcard/Pixelify/config.prop"
else
    vk_loc="$MODPATH/config.prop"
fi

# Have user option to skip vol keys
export TURN_OFF_SEL_VOL_PROMPT=0

# Setup Volume keys for installation
# Check if it is no-Vk zip
if [ "$VOL_KEYS" -eq 0 ]; then
    log "- Skipping Vol Keys -"
    if [ -f /sdcard/Pixelify/config.prop ]; then
        log ""
        log " Using config: $vk_loc"
        VKSEL=no_vksel
    else
        error "X Config not found installation"
        log "- Config is now placed at /sdcard/Pixelify/config.prop"
        mkdir -p /sdcard/Pixelify
        cp -f $vk_loc /sdcard/Pixelify/config.prop
        error "- Please configure it and reinstall pixelify"
        abort
    fi
else
    # Use keytest to assign method (chooseport or old)
    if keytest; then
        echo "- Using chooseport method for Volume keys" >>$logfile
        VKSEL=chooseport
    else
        VKSEL=chooseportold
        echo "- using chooseportold method for Volume Keys" >>$logfile
        error "  ! Legacy device detected! Using old keycheck method"
        log " "
        log "- Vol Key Programming -"
        log "  Press Vol Up Again:"
        $VKSEL "UP"
        log "  Press Vol Down"
        $VKSEL "DOWN"
    fi
fi

# Installtion
log ""
blue "- Installing Pixelify Module"
green "- Extracting Files...."
log ""
error "- Please don't turn off screen between the installation"
log ""
echo "- Extracting Files ..." >>$logfile

# install Google Health services for Android Pie and Above
# if [ $API -ge 28 ]; then
#     tar -xf $MODPATH/files/tur.tar.xz -C $MODPATH/system$product/priv-app
# fi

# Allow users to use config with Volume key installation if config is placed
if [ -f /sdcard/Pixelify/config.prop ] && [ $VOL_KEYS -eq 1 ]; then
    log "  (Config detected)"
    log "  Do you want to use config for installation?"
    log "   Vol Up += Yes"
    log "   Vol Down += No"
    if $VKSEL; then
        VKSEL=no_vksel
        VOL_KEYS=0
    fi
fi

# Allow now to force enable network
FIRST_ONLINE_TIME=1

# Options menu to log
echo "$var_menu" >>$logfile

# Internal Spoofing
if [ ! -z $exact_prop ] && [ $API -ge 31 ]; then
    print "  Disclaimer: This Feature is in BETA"
    log "  This features is only intended to Quick Phrase."
    #print "  Disabling Internal Spoofing can break OTA Update (rom dependent)"
    log "  If it doesn't work properly then it causes issues to Google app"
    log "  If you are not aware of We wont recommended to enable it."
    print ""
    log "  Do you want to disable Internal spoofing of rom?"
    log "  Note: This may break ota update of your rom"
    log "   Vol Up += Yes"
    log "   Vol Down += No"
    no_vk "DISABLE_INTERNAL_SPOOFING"
    if $VKSEL; then
        echo " " >>$MODPATH/system.prop
        echo "$exact_prop=redfin" >>$MODPATH/system.prop
    fi
fi

# Google Photos Unlimited Backup Setup
if [ $TENSOR -eq 1 ]; then
    print "(TENSOR CHIPSET DETECTED)"
    log "  Do you want to enable Google Photos Unlimited Backup?"
    log "  Note: Photos unblur won't work and Magic eraser may work slower"
    log "   Vol Up += Yes"
    log "   Vol Down += No"
    no_vk "ENABLE_PHOTOS_UNLIMITED"
    if $VKSEL; then
        echo "- Enabling Unlimited storage in this Tensor chipset device" >>$logfile
        drop_sys
    else
        echo "- Disabling Unlimited storage in this Tensor chipset device" >>$logfile
        rm -rf $MODPATH/zygisk $MODPATH/zygisk_1
    fi
fi
###################################################################################################################################################################################################################
if [ $API -ge 31 ]; then
print ""
log "Do you want to activate global spoofing?"
log "It may break roms OTAs and show a mesage to update your pixel"
log "   Vol Up += Yes"
log "   Vol Down += No"
no_vk "GLOBAL_SPOOFING"
if $VKSEL; then
    GLOBAL_SPOOF=1
    echo "- Global Spoofing Enabled" >>$logfile
    cat << 'EOF' >> $MODPATH/post-fs-data.sh
resetprop -n "gsm.operator.iso-country" "us"
resetprop -n "gsm.sim.operator.iso-country" "us"
resetprop -n "persist.sys.country" "us"
resetprop -n "ro.product.locale.region" "US"
resetprop -n "ro.product.locale.language" "en"
resetprop -n "persist.sys.language" "en"
resetprop -n "ro.product.brand" "google"
resetprop -n "ro.product.manufacturer" "Google"
resetprop -n "ro.product.model" "Pixel 10 Pro"
resetprop -n "ro.product.device" "blazer"
resetprop -n "ro.product.name" "blazer_beta"
resetprop -n "ro.build.product" "blazer"
resetprop -n "ro.build.device" "blazer"
resetprop -n "ro.build.fingerprint" "google/blazer_beta/blazer:16/BP41.250916.015.A1/14331773:user/release-keys"
EOF
else
    GLOBAL_SPOOF=0
    echo "- Global Spoofing Disabled" >>$logfile
fi
fi
# Disable Android System intelligence as there it already installed.
if [ ! -z $(pm list packages -s | grep com.google.android.as) ]; then
    echo " - Android System Intelligence is installed as system app" >>$logfile
    # Dont disable incase if Android System Intelligence gets system app via Pixelify (case when user installs Pixelify 2nd time)
    if [ -z $(cat $pix/apps_temp.txt | grep "dp-$API") ]; then
        if [ $API -eq 30 ] && [ ! -z $($MODPATH/addon/dumpsys package com.google.android.as | grep versionName | grep pixel5) ]; then
            echo " - Ignoring Android System Intelligence due to Pixel 5 version already installed" >>$logfile
            DPAS=0
        elif [ $API -le 29 ]; then
            DPAS=0
            echo " - Ignoring Android System Intelligence because it's already installed" >>$logfile
        fi
    fi
fi

# Android Oreo and below dont have Android System Intelligence
if [ $API -le 27 ]; then
    echo " - Disabling Android System Intelligence installation due to the api not supported" >>$logfile
    DPAS=0
fi

# For now disable Android System Intelligence of ONE Ui, as some bootloop reported before
if [ "$(getprop ro.product.vendor.manufacturer)" == "samsung" ]; then
    if [ ! -z "$(getprop ro.build.PDA)" ]; then
        echo " - Disabling Android System Intelligence installation on samsung devices" >>$logfile
        DPAS=0
    fi
fi

#[ -f /product/etc/firmware/music_detector.sound_model ] && rm -rf $MODPATH/system/etc/firmware && NOT_REQ_SOUND_PATCH=1

# Android System Intelligence installation
if [ $DPAS -eq 1 ]; then
    echo " - Installing Android System Intelligence" >>$logfile
    # If there is a backup, use it
    if [ -f /sdcard/Pixelify/backup/dp-$API.tar.xz ]; then
        echo " - Backup Detected for Android System Intelligence" >>$logfile
        REMOVE="$REMOVE $DP"
        # Check Backup is of latest version or not.
        if [ "$(cat /sdcard/Pixelify/version/dp-$API.txt)" != "$DPVERSION" ] || [ $SEND_DPS -eq 1 ] || [ ! -f /sdcard/Pixelify/version/dp-$API.txt ]; then
            echo " - New Version Detected for Android System Intelligence" >>$logfile
            echo " - Installed version: $(cat /sdcard/Pixelify/version/dp-$API.txt) , New Version: $DPVERSION " >>$logfile
            log "  (Network Connection Needed)"
            log "  New version Detected of Android System Intelligence"
            log "  Do you Want to update or use Old Backup?"
            log "  Version: $DPVERSION"
            log "  Size: $DPSIZE Mb"
            log ""
            log "   Vol Up += Update"
            log "   Vol Down += Use Old Backup"
            no_vk "UPDATE_DPS"
            if $VKSEL; then
                online
                # Download and Install Latest one
                if [ $internet -eq 1 ]; then
                    echo " - Downloading and installing new backup for Android System Intelligence" >>$logfile
                    cd $MODPATH/files
                    rm -rf /sdcard/Pixelify/backup/dp-$API.tar.xz /sdcard/Pixelify/backup/dp-net-$API.tar.xz /sdcard/Pixelify/version/dp.txt /sdcard/Pixelify/version/dp-$API.txt
                    # Fetch and download Android system Intelligence
                    if [ $API -eq 31 ] || [ $API -eq 32 ]; then
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/asi-new-31.tar.xz -o dp-$API.tar.xz &>/proc/self/fd/$OUTFD
                    elif [ $API -ge 33 ]; then
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/asis-new-$API.tar.xz -o dp-$API.tar.xz &>/proc/self/fd/$OUTFD
                    else
                        $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/dp-$API.tar.xz -O &>/proc/self/fd/$OUTFD
                    fi
                    cp -f $MODPATH/files/dp-$API.tar.xz /sdcard/Pixelify/backup/dp-$API.tar.xz
                    echo "$DPVERSION" >>/sdcard/Pixelify/version/dp-$API.txt
                    cd /
                    print ""
                    print "- Creating Backup"
                else
                    print ""
                    error " ! No internet detected"
                    print ""
                    log "! Using Old backup for now."
                    echo " ! Using Old backup for Android System Intelligence due to no internet services" >>$logfile
                    print ""
                fi
            else
                echo " - Using Old backup for Android System Intelligence" >>$logfile
                print ""
            fi
        fi
        # Install Now now playing (option is disabled)
        #now_playing
        log "- Installing Android System Intelligence"
        log ""
        # Copy Android System Intelligence overlay to grant default permissions
        cp -f $MODPATH/files/PixelifyDPS.apk $MODPATH/system/product/overlay/PixelifyDPS.apk
        tar -xf /sdcard/Pixelify/backup/dp-$API.tar.xz -C $MODPATH/system$product/priv-app
        echo dp-$API >$pix/app2.txt
    else
        # Give option to user wether to download or not in case no backup is detected
        log ""
        echo " - No backup Detected for Android System Intelligence" >>$logfile
        log "  (Network Connection Needed)"
        log "  Do you want to install and Download Android System Intelligence?"
        log "  Size: $DPSIZE Mb"
        log "   Vol Up += Yes"
        log "   Vol Down += No"
        no_vk "ENABLE_DPS"
        if $VKSEL; then
            # Checker internet is available or not
            online
            if [ $internet -eq 1 ]; then
                log "- Downloading Android System Intelligence"
                echo " - Downloading and installing Android System Intelligence" >>$logfile
                print ""
                cd $MODPATH/files
                # Fetch and download Android System intelligence
                if [ $API -eq 31 ] || [ $API -eq 32 ]; then
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/asi-new-31.tar.xz -o dp-$API.tar.xz &>/proc/self/fd/$OUTFD
                elif [ $API -ge 33 ]; then
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/asis-new-$API.tar.xz -o dp-$API.tar.xz &>/proc/self/fd/$OUTFD
                else
                    $MODPATH/addon/curl https://gitlab.com/Kingsman-z/pixelify-files/-/raw/master/dp-$API.tar.xz -O &>/proc/self/fd/$OUTFD
                fi
                cd /
                #now_playing
                print ""
                log "- Installing Android System Intelligence"
                # copy Android system intelligence overlay to give defualt permissions
                cp -f $MODPATH/files/PixelifyDPS.apk $MODPATH/system/product/overlay/PixelifyDPS.apk

                # Extract Android system Intelligence
                tar -xf $MODPATH/files/dp-$API.tar.xz -C $MODPATH/system$product/priv-app
                echo dp-$API >$pix/app2.txt

                # Remove System Android system Intelligence
                REMOVE="$REMOVE $DP"

                # Create backup
                log ""
                log "  Do you want to create backup of Android System Intelligence?"
                log "  so that you don't need redownload it every time."
                log "   Vol Up += Yes"
                log "   Vol Down += No"
                no_vk "BACKUP_DPS"
                if $VKSEL; then
                    echo " - Creating backup for Android System Intelligence" >>$logfile
                    log "- Creating Backup"
                    mkdir -p /sdcard/Pixelify/backup
                    rm -rf /sdcard/Pixelify/backup/dp-$API.tar.xz /sdcard/Pixelify/backup/dp-net-$API.tar.xz /sdcard/Pixelify/version/dp.txt /sdcard/Pixelify/version/dp-$API.txt
                    cp -f $MODPATH/files/dp-$API.tar.xz /sdcard/Pixelify/backup/dp-$API.tar.xz
                    print ""
                    mkdir /sdcard/Pixelify/version
                    echo "$DPVERSION" >>/sdcard/Pixelify/version/dp-$API.txt
                    green " - Done"
                fi
            else
                error " ! No internet detected"
                print ""
                error "- Skipping Android System Intelligence"
                print ""
                echo " - Skipping Android System Intelligence due to no internet services" >>$logfile
            fi
        fi
    fi
    # Install it as user app also along with system app (Android 12 had some crashes ony with system app)
    pm install $MODPATH/system/product/priv-app/DevicePersonalizationPrebuiltPixel*/*.apk &>/dev/null
    [ $API -ge 31 ] && pm install $MODPATH/system/product/priv-app/DeviceIntelligenceNetworkPrebuilt/*.apk &>/dev/null
    rm -rf $MODPATH/system/product/priv-app/asi_up.apk
else
    print ""
fi

# Google Photos App
gphotos8

# Google Dialer Feature installation ( helper script install_dialer.sh
install_dialer

#else
#    # Remove Google dialer files if user doesn't want to enable it
#    chmod 755 /data/data/com.google.android.dialer/files/phenotype
#    sed -i -e "s/cp -Tf $MODDIR\/com.google.android.dialer/#cp -Tf $MODDIR\/com.google.android.dialer/g" $MODPATH/service.sh
#    sed -i -e "s/chmod 500 \/data\/data\/com.google.android.dialer\/files\/phenotype/#chmod 500 \/data\/data\/com.google.android.dialer\/files\/phenotype/g" $MODPATH/service.sh
#    rm -rf $MODPATH/system$product/overlay/PixelifyGD.apk
#fi

# Next Generation assistant installation ( helper script install_nga.sh)
install_nga
if [ $NO_NGA = true ]; then
 systemize_velvet
 # If the user selects no to the NGA installation still will velvet (google app) be installed as system app
fi

# Install apps (now playing & journal, helper script install_apps.sh) 
install_apps

#if [ -d /data/data/com.google.android.googlequicksearchbox ] && [ $API -ge 36 ]; then
#    log "  Google is installed."
#    log "  Do you want to installed AirDrop Quick Share? [UNTESTED]"
#    log "  (you will need to have quick share installed and pixel 10 spoof)"
#    log "   Vol Up += Yes"
#    log "   Vol Down += No"
#    no_vk "QUICK_SHARE"
#    if $VKSEL; then
#        log " - Installing Quick share extension" >>$logfile
#        log "- Installing Quick share extension"
#        log ""
#        . $MODPATH/installAPK.sh mosey.apkm
#     fi
#fi
#if [ -d /data/data/com.google.android.googlequicksearchbox ]; then
#   log ""
#   log " Google its installed."
#   log " Do you want to install other pixel apps? (Weather, recorder, etc)"
#   log " Vol up += Yes"
#   log " Vol down += No"
#   no_vk "PIXEL_APPS"
#   if $VKSEL; then
#       log ""
#       log "Installing pixel apps"
#       log ""
#       TODO update with apps names
#       . $MODPATH/installAPK.sh 
#       . $MODPATH/installAPK.sh	
#fi

# Pixel Studio
#if [ -d /data/data/com.google.android.googlequicksearchbox ] && [ $API -ge 29 ] && [ $TARGET_DEVICE_ONEUI -eq 0 ]; then
#    log "  Google is installed."
#   log "  Do you want to install Pixel Studio"
#    log "   Vol Up += Yes"
#    log "   Vol Down += No"
#    no_vk "INSTALL_STUDIO"
#    if $VKSEL; then
#        echo " - Installing Pixel Studio" >>$logfile
#        log "- Installing Pixel Studio"
#        log ""
#        . $MODPATH/installAPK.sh Studio.apkm
#     fi
#fi

# Pixel Wallpapers (helper script install_walllpapers.sh)
install_wallpapers

# Enable using monet bootanimation as they have themed_bootanimation function
[ $API -ge 32 ] && MONET_BOOTANIMATION=1

# checking Monet is supported or not
is_monet

# Pixel Launcher (helper script install_launcher.sh)
install_launcher

# Pixel bootanimation (helper script install_bootanimation.sh)
install_bootanimation
if [ BUILT_WITH_MOSEY_SUPPORT ]; then
 echo "Built with mosey supported, asking user" >> $logfile
 log "  Do you want air drop support?"
 log "  Note: GKI 5.10, 5.15 and 6.1 only"
 log "    Vol Up += Yes"
 log "    Vol Down += No"
 no_vk "MOSEY_SUPPORT"
 if $VKSEL; then
   # This block will be replaced with the mosey code at compilation
   #CUSTOMIZE.SH_MOSEY_STUB
   :
  else
   log "Selected no, skipping"
 fi
else
 log "This build doesnt have mosey, skipping"
 echo "Built with mosey unsupported, compile with submodules" >> $logfile
fi

#Adding Google san font.
log ""
#print "  (NOTE: Playstore or Google or GMS crashes then dont enable it)"
log "  Do you want add Google San Fonts?"
log "    Vol Up += Yes"
log "    Vol Down += No"
no_vk "GSAN_FONT"
if $VKSEL; then
    patch_font
else
    rm -rf $MODPATH/system/product/overlay/PixelifyGsan*.apk
    rm -rf $MODPATH/system/product/overlay/GInterOverlay.apk
fi
# rm -rf $MODPATH/system/product/overlay/PixelifyGsan*.apk
# rm -rf $MODPATH/system/product/overlay/GInterOverlay.apk
# rm -rf $MODPATH/system/fonts

# Google Settings service
if [ $API -ge 28 ] && [ $TARGET_DEVICE_OP12 -eq 0 ]; then
    log "  Do you want to install Google settings service?"
    # log "  (Battery Widget)"
    log "    Vol Up += Yes"
    log "    Vol Down += No"
    no_vk "ENABLE_GSI"
    if $VKSEL; then
        SI=$(find /system -name *SettingsIntelligence* | grep -v overlay | grep -v "\.")
        tar -xf $MODPATH/files/sig.tar.xz -C $MODPATH/system$product/priv-app
        # cp -f $MODPATH/files/PixelifySettingsIntelligenceGoogleOverlay.apk $MODPATH/system/product/overlay/PixelifySettingsIntelligenceGoogleOverlay.apk
        # REMOVE="$REMOVE $SI"
    else
        echo " - Skipping Google settings intelligence" >>$logfile
    fi
fi

# Flipendo is temporarily disabled as it was causing issues with some devices (fastboot crash)

# Rboard app fixes
if [ ! -z "$(pm list packages | grep de.dertyp7214.rboardthememanager)" ]; then
    log ""
    log "- Rboard app is installed !!"
    log ""
    log "  Do you want to apply fix for Rboard by disabling GMS overriding flags?"
    log "  Note: Pixelify will still try to patch other method"
    log "    Vol Up += Yes"
    log "    Vol Down += No"
    no_vk "DISABLE_GBOARD_GMS_OVERRIDE"
    if $VKSEL; then
        DISABLE_GBOARD_GMS=1
    fi
fi

# Google keyboard
if [ ! -z "$(pm list packages | grep com.google.android.inputmethod.latin)" ]; then
    log ""
    log " Google keyboard is installed."
    log "- Enabling pixel exclusive features"
    [ $API -ge 31 ] && log "- Enabling NGA Voice typing (If Nga is installed)"

    # Flags patch for Gboard
    echo " - Patching Google Keyboard's bools" >>$logfile
    patch_gboard

    if [ -z $(pm list packages -s com.google.android.inputmethod.latin) ] && [ -z "$(cat $pix/apps_temp.txt | grep gboard)" ]; then
        error "- GBoard is not installed as a system app !!"
        log "- Making Gboard a system app"
        echo " - Making Google Keyboard a system app" >>$logfile
        cp -r $app/com.google.android.inputmethod.latin*/. $MODPATH/system/product/app/LatinIMEGooglePrebuilt
        mv $MODPATH/system/product/app/LatinIMEGooglePrebuilt/base.apk $MODPATH/system/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk
        rm -rf $MODPATH/system/product/app/LatinIMEGooglePrebuilt/oat
        #mv $MODPATH/files/privapp-permissions-com.google.android.inputmethod.latin.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.inputmethod.latin.xml
        echo "gboard" >>$pix/app2.txt
    elif [ ! -z "$(cat $pix/apps_temp.txt | grep gboard)" ]; then
        log "- GBoard is not installed as a system app !!"
        echo " - Making Google Keyboard as system app" >>$logfile
        log "- Making Gboard a system app"
        cp -r $app/com.google.android.inputmethod.latin*/. $MODPATH/system/product/app/LatinIMEGooglePrebuilt
        mv $MODPATH/system/product/app/LatinIMEGooglePrebuilt/base.apk $MODPATH/system/product/app/LatinIMEGooglePrebuilt/LatinIMEGooglePrebuilt.apk
        rm -rf $MODPATH/system/product/app/LatinIMEGooglePrebuilt/oat
        #mv $MODPATH/files/privapp-permissions-com.google.android.inputmethod.latin.xml $MODPATH/system/product/etc/permissions/privapp-permissions-com.google.android.inputmethod.latin.xml
        echo "gboard" >>$pix/app2.txt
    fi
fi

# Speech Services by Google
if [ ! -z $(pm list packages com.google.android.tts) ]; then
    if [ -z $(pm list packages -s com.google.android.tts) ] && [ ! -f /data/adb/modules/PixelifyNext/system/product/app/GoogleTTS/GoogleTTS.apk ]; then
        install_tts
    elif [ -f /data/adb/modules/PixelifyNext/system$product/app/GoogleTTS/GoogleTTS.apk ]; then
        install_tts
    fi
else
    error ""
    error " ! It is recommended to install Google TTS"
    error " ! If you face any problem regarding call screening or call recording"
    [ $API -ge 31 ] && error " ! It is required for Live caption data downloading"
    error " ! Then Install GoogleTTS via playstore"
    error " ! Reinstall module to make it system app"
    error ""
fi

blue " - Patching GMS flags to enable features"
blue " - This may take a minute or two"

# Permissions for apps
for j in $MODPATH/system/*/priv-app/*/*.apk; do
    set_perm_app $j
done
for j in $MODPATH/system/priv-app/*/*.apk; do
    set_perm_app $j
done

# Patching Sound trigger
#sound_trigger_patch

# Disable features as per API
if [ $API -ge 32 ]; then
    rm -rf $MODPATH/system/product/overlay/PixelifyPixel12.apk
fi

if [ $API -ge 31 ]; then
    rm -rf $MODPATH/system/product/overlay/PixelifyPixel.apk
    rm -rf $MODPATH/system/product/overlay/PixelifyApi30.apk
    sed -i -e 's/<feature name="com.google.android.feature.ZERO_TOUCH" \/>/<!-- <feature name="com.google.android.feature.ZERO_TOUCH" \/> -->/g' $MODPATH/system/product/etc/sysconfig/pixelifyexperience.xml
    if [ $WREM -eq 1 ]; then
        rm -rf $MODPATH/system/product/priv-app/WallpaperPickerGoogleRelease
    fi
fi

if [ $API -le 30 ]; then
    rm -rf $MODPATH/system$product/overlay/PixelifyPixelS.apk
fi

if [ $API -le 29 ]; then
    sed -i -e "s/device_config/#device_config/g" $MODPATH/service.sh
    rm -rf $MODPATH/system$product/priv-app/SimpleDeviceConfig
fi

if [ $API -le 27 ]; then
    sed -i -e "s/bool_patch AdaptiveCharging__v1_enabled/#bool_patch AdaptiveCharging__v1_enabled/g" $MODPATH/service.sh
fi

# OOS 12+ Fix
oos_fix

# Fix Permission controller
if [ $ROM_TYPE != "custom" ]; then
    rm -rf $MODPATH/system/product/overlay/Pixelify.apk
fi

# Setting permisions
set_perm_recursive $MODPATH 0 0 0755 0644

for i in $MODPATH/system/vendor/overlay $MODPATH/system$product/overlay $MODPATH/system$product/priv-app/* $MODPATH/system$product/app/*; do
    set_perm_recursive $i 0 0 0755 0644
done

# Regenerate overlay list
rm -rf /data/resource-cache/overlays.list
find /data/resource-cache/ -name "*Pixelify*" -exec rm -rf {} \;
find /data/resource-cache/ -name "*PixelLauncherOverlay*" -exec rm -rf {} \;

#make some permissions not enforced
pm set-permission-enforced android.permission.READ_DEVICE_CONFIG false
pm set-permission-enforced android.permission.SUSPEND_APPS. false

# Fix unknown creation of data folder
rm -rf $MODPATH/system/product/data

# Clear package cache
rm -rf /data/system/package_cache/*

# Updating vars
rm -rf $pix/apps_temp.txt $MODPATH/zygisk_1
mv $pix/app2.txt $pix/app.txt

# Replace apps
REMOVE="$(echo "$REMOVE" | tr ' ' '\n' | sort -u)"
REPLACE="$REMOVE"

settings put secure show_qr_code_scanner_setting true
settings put secure lock_screen_show_qr_code_scanner true

#Clean Up
rm -rf $MODPATH/files
rm -rf $MODPATH/spoof.prop
rm -rf $MODPATH/inc.prop

# create Uninstaller
[ -d $PIXELIFYUNS ] && rm -rf $PIXELIFYUNS
mkdir -p $PIXELIFYUNS
mv $MODPATH/module-uninstaller.prop $PIXELIFYUNS/module.prop
mv $MODPATH/service-uninstaller.sh $PIXELIFYUNS/service.sh
cp -r $MODPATH/flags_* $PIXELIFYUNS
rm -rf $MODPATH/flags_*
cp -f $MODPATH/deviceconfig.txt $PIXELIFYUNS/deviceconfig.txt
cp -f $MODPATH/utils.sh $PIXELIFYUNS/utils.sh
cp -f $MODPATH/vars.sh $PIXELIFYUNS/vars.sh
cp -r $MODPATH/addon $PIXELIFYUNS
touch $PIXELIFYUNS/first

mkdir -p $MODPATH/system/bin
mv $MODPATH/pixelify.sh $MODPATH/system/bin/pixelify
chmod 0755 $MODPATH/system/bin/pixelify

echo " 
- Replacing apps -
$REMOVE
------------------
" >>$logfile

green " ---- Installation Finished ----" >>$logfile

green ""
green "- Done"
green ""
green " - Installation logs were saved as /sdcard/Pixelify/logs.txt"
