#!/system/bin/sh
# Phenotype Microhooks Flag Patcher for Dialer, Call Screen & Pixel Features
# Compatible with new Phenotype DB versions (Flags, FlagOverrides, FlagOverride tables)
MODDIR=${0%/*}
[ -n "$MODPATH" ] && MODDIR="$MODPATH"

SQLITE_BIN=""
if [ -f "$MODDIR/addon/sqlite3" ]; then
    chmod 0755 "$MODDIR/addon/sqlite3" 2>/dev/null
    SQLITE_BIN="$MODDIR/addon/sqlite3"
elif command -v sqlite3 >/dev/null 2>&1; then
    SQLITE_BIN="$(command -v sqlite3)"
elif [ -x /system/bin/sqlite3 ]; then
    SQLITE_BIN="/system/bin/sqlite3"
fi

if [ -z "$SQLITE_BIN" ]; then
    echo "Warning: sqlite3 binary not found for microhooks patcher"
    return 1 2>/dev/null || exit 0
fi

DB_PATHS="/data/data/com.google.android.gms/databases/phenotype.db /data/user_de/0/com.google.android.gms/databases/phenotype.db /data/data/com.google.android.dialer/databases/phenotype.db /data/user_de/0/com.google.android.dialer/databases/phenotype.db"
STATUS_FILE="$MODDIR/flags_status"

# Function signature: patch_flag <package_name> <flag_name> <true/false|1/0>
patch_flag() {
    PKG="$1"
    FLAG="$2"
    VAL="$3"
    
    [ -z "$PKG" -o -z "$FLAG" ] && return 1

    case "$(echo "$VAL" | tr '[:upper:]' '[:lower:]')" in
        true|1) BVAL=1 ;;
        *) BVAL=0 ;;
    esac

    for DB in $DB_PATHS; do
        if [ -f "$DB" ]; then
            chmod 0666 "$DB" 2>/dev/null
            "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = $BVAL WHERE packageName='$PKG' AND name='$FLAG';" 2>/dev/null || true
            "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='$PKG' AND name='$FLAG';" 2>/dev/null || true
            "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('$PKG', '', '$FLAG', 0, $BVAL, 0);" 2>/dev/null || true
            "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('$PKG', '', '$FLAG', 0, $BVAL, 1);" 2>/dev/null || true
            "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('$PKG', '', '$FLAG', 0, $BVAL, 1);" 2>/dev/null || true
        fi
    done
}

patch_all_microhooks() {
    # Call Screen (Atlas / Beesly) & Hold for Me (Dobby)
    for flag in 45624401 45628184 45628185 45633861 45645737 45667116 45667117 45667118 45740943 45748547 45664158 45727673 45661436 45684622 45728331 45731943 45684804 45629794 45684179 45722860 45667177 45676586 45413174 45417169 45665235 45408594 45676588 45676587 45676589; do
        patch_flag "com.google.android.dialer.directboot" "$flag" true
    done
    patch_flag "com.google.android.dialer.directboot" "45730953" false

    # Call Recording
    for flag in G__enable_call_recording G__use_call_recording_geofence_overrides G__force_within_call_recording_geofence_value G__force_within_crosby_geofence_value; do
        patch_flag "com.google.android.dialer" "$flag" true
    done

    # AICore & PSI
    patch_flag "com.google.android.apps.pixel.psi" "psi_enable_apps" true

    # Now Playing
    patch_flag "com.google.android.apps.miphone.aiai.nowplaying" "now_playing_notification_history_enabled" true
}

patch_all_microhooks

rm -rf /data/data/com.google.android.dialer/files/phenotype/* 2>/dev/null
rm -rf /data/user_de/0/com.google.android.dialer/files/phenotype/* 2>/dev/null

if [ "$1" = "boot" ] || [ "$SERVICE_BOOT" = "1" ]; then
    am force-stop com.google.android.dialer 2>/dev/null || true
    am force-stop com.google.android.gms 2>/dev/null || true
    am force-stop com.google.android.aicore 2>/dev/null || true
    am force-stop com.google.android.apps.pixel.psi 2>/dev/null || true
fi

echo "ACTIVE|35|48" > "$STATUS_FILE"
echo "Microhooks Phenotype flags successfully patched."
