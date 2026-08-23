#!/system/bin/sh
MODDIR=${0%/*}

. $MODDIR/vars.sh 2>/dev/null
. $MODDIR/utils.sh 2>/dev/null

sqlite=$MODDIR/addon/sqlite3
chmod 0755 $sqlite 2>/dev/null
[ -f $MODDIR/system/bin/pixelify ] && chmod 0755 $MODDIR/system/bin/pixelify 2>/dev/null

# --- Live Boot Logger ---
# Rotates logs so live-logging-boot1.log is current boot and live-logging-boot2.log is previous boot.
# Overwritten after 2 successful boots. Accessible in recovery at $MODDIR/live-logging-boot1.log.

rotate_live_logs() {
    LOG1="$MODDIR/live-logging-boot1.log"
    LOG2="$MODDIR/live-logging-boot2.log"

    if [ -f "$LOG1" ]; then
        mv -f "$LOG1" "$LOG2"
    fi

    TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
    echo "==================================================" > "$LOG1"
    echo "PixelifyNext Live Recovery Log" >> "$LOG1"
    echo "Boot Timestamp : $TIMESTAMP" >> "$LOG1"
    echo "Device Model   : $(getprop ro.product.model)" >> "$LOG1"
    echo "Device Product : $(getprop ro.product.name)" >> "$LOG1"
    echo "Android SDK    : $(getprop ro.build.version.sdk)" >> "$LOG1"
    echo "Fingerprint    : $(getprop ro.build.fingerprint)" >> "$LOG1"
    echo "==================================================" >> "$LOG1"
    echo "" >> "$LOG1"

    start_live_logger "$LOG1" &
}

start_live_logger() {
    TARGET_LOGFILE="$1"
    
    # Capture Zygisk module tags, runtime crashes, system errors, and feature app logs
    logcat -v time 2>/dev/null | \
    grep -E --line-buffered -i "(Pixelify|AndroidRuntime|crash_dump|DEBUG|Zygote|SystemServer|Fatal|Exception|com\.google\.android|\.dialer|\.photos|\.aicore|\.gms)" >> "$TARGET_LOGFILE" &
}

rotate_live_logs

# --- Bootloop Preventer ---
sleep 5

MAIN_ZYGOTE_NICENAME=zygote
CPU_ABI=$(getprop ro.product.cpu.abi)
[ "$CPU_ABI" = "arm64-v8a" -o "$CPU_ABI" = "x86_64" ] && MAIN_ZYGOTE_NICENAME=zygote64

ZYGOTE_PID1=$(pidof "$MAIN_ZYGOTE_NICENAME")
sleep 15
ZYGOTE_PID2=$(pidof "$MAIN_ZYGOTE_NICENAME")
sleep 15
ZYGOTE_PID3=$(pidof "$MAIN_ZYGOTE_NICENAME")

PIDS=0

if [ -n "$ZYGOTE_PID1" ] && [ "$ZYGOTE_PID1" = "$ZYGOTE_PID2" ] && [ "$ZYGOTE_PID2" = "$ZYGOTE_PID3" ]; then
    PIDS=1
fi

if [ $PIDS -eq 0 ]; then
    sleep 15
    ZYGOTE_PID4=$(pidof "$MAIN_ZYGOTE_NICENAME")
    if [ -n "$ZYGOTE_PID3" ] && [ "$ZYGOTE_PID3" = "$ZYGOTE_PID4" ]; then
        PIDS=1
    elif [ "$(getprop init.svc.bootanim)" != "stopped" ]; then
        echo -n >> $MODDIR/disable
        reboot
    fi
fi

while [ ! -d /data/data ]; do
  sleep 1
done

# Dialer permissions fix
PKG_NAME="com.google.android.dialer"
DATA_PATH_USER="/data/user/0/$PKG_NAME"
DATA_PATH_DATA="/data/data/$PKG_NAME"
DIR_TO_CREATE="$DATA_PATH_USER/files/photos/raw"

mkdir -p "$DIR_TO_CREATE"
if [ -d "$DATA_PATH_USER" ]; then
  APP_UID=$(stat -c %u "$DATA_PATH_USER" 2>/dev/null)
  if [ -n "$APP_UID" ] && [ "$APP_UID" -gt 10000 ]; then
    chown -R $APP_UID:$APP_UID "$DATA_PATH_USER" 2>/dev/null
    chmod -R 0700 "$DATA_PATH_USER" 2>/dev/null
    if [ -L "$DATA_PATH_DATA" ]; then
      chown -R $APP_UID:$APP_UID "$DATA_PATH_DATA" 2>/dev/null
      chmod -R 0700 "$DATA_PATH_DATA" 2>/dev/null
    fi
  fi
fi

# Region & Locale props
resetprop -n gsm.operator.iso-country us
resetprop -n gsm.sim.operator.iso-country us
resetprop -n persist.sys.country us
resetprop -n ro.product.locale.region US
resetprop -n ro.product.locale.language en
resetprop -n persist.sys.language en

# Patch Phenotype microhooks flags on boot
[ -f $MODDIR/patch_microhooks.sh ] && . $MODDIR/patch_microhooks.sh

# Ensure SELinux contexts for mounted partitions
chcon -R u:object_r:system_file:s0 $MODDIR/system 2>/dev/null || true
[ -d $MODDIR/system/product ] && chcon -R u:object_r:system_file:s0 $MODDIR/system/product 2>/dev/null || true
[ -d $MODDIR/system/product/app ] && chcon -R u:object_r:product_app_file:s0 $MODDIR/system/product/app 2>/dev/null || true
[ -d $MODDIR/system/product/priv-app ] && chcon -R u:object_r:product_priv_app_file:s0 $MODDIR/system/product/priv-app 2>/dev/null || true
[ -d $MODDIR/system/product/overlay ] && chcon -R u:object_r:product_overlay_file:s0 $MODDIR/system/product/overlay 2>/dev/null || true
[ -d $MODDIR/system/product/etc ] && chcon -R u:object_r:product_etc_file:s0 $MODDIR/system/product/etc 2>/dev/null || true

# Stub for replacing with mosey code
#SERVICE.SH_MOSEY_STUB
