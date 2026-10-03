#!/system/bin/sh
# Phenotype Microhooks & Direct SharedPrefs Patcher for Dialer, Call Screen & Pixel Features
MODDIR=${0%/*}
[ -n "$MODPATH" ] && MODDIR="$MODPATH"

SQLITE_BIN=""
for cand in \
    "$TMPDIR/addon/sqlite3" \
    "$TMPDIR/bin/sqlite3" \
    "$MODPATH/addon/sqlite3" \
    "$MODPATH/bin/sqlite3" \
    "$MODDIR/addon/sqlite3" \
    "$MODDIR/bin/sqlite3" \
    "/data/adb/modules/Pixelify-Next/addon/sqlite3" \
    "/data/adb/modules/Pixelify/addon/sqlite3" \
    "/data/adb/modules/CallScreen/bin/sqlite3" \
    "/system/bin/sqlite3" \
    "/system/xbin/sqlite3" \
    "/system/vendor/bin/sqlite3_mosey" \
    "/vendor/bin/sqlite3_mosey" \
    "/vendor/bin/sqlite3"; do
    if [ -f "$cand" ]; then
        chmod 0755 "$cand" 2>/dev/null
        SQLITE_BIN="$cand"
        break
    fi
done

if [ -z "$SQLITE_BIN" ] && command -v sqlite3 >/dev/null 2>&1; then
    SQLITE_BIN="$(command -v sqlite3)"
fi

DB_PATHS="/data/data/com.google.android.gms/databases/phenotype.db /data/user_de/0/com.google.android.gms/databases/phenotype.db /data/data/com.google.android.dialer/databases/phenotype.db /data/user_de/0/com.google.android.dialer/databases/phenotype.db"
STATUS_FILE="$MODDIR/flags_status"

DIALER_PKGS="com.google.android.dialer com.google.android.dialer.directboot com.google.android.dialer.directboot#com.google.android.dialer com.google.android.dialer#com.google.android.dialer com.google.android.dialer.callscreening"

# 1. Function to patch sqlite phenotype db across all dialer package targets
patch_flag() {
    FLAG="$1"
    VAL="$2"
    
    [ -z "$FLAG" ] && return 1

    case "$(echo "$VAL" | tr '[:upper:]' '[:lower:]')" in
        true|1) BVAL=1 ;;
        *) BVAL=0 ;;
    esac

    for PKG in $DIALER_PKGS; do
        for DB in $DB_PATHS; do
            if [ -f "$DB" -a -n "$SQLITE_BIN" ]; then
                chmod 0666 "$DB" 2>/dev/null
                "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = $BVAL WHERE packageName='$PKG' AND name='$FLAG';" 2>/dev/null || true
                "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='$PKG' AND name='$FLAG';" 2>/dev/null || true
                "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('$PKG', '', '$FLAG', 0, $BVAL, 0);" 2>/dev/null || true
                "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('$PKG', '', '$FLAG', 0, $BVAL, 1);" 2>/dev/null || true
                "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('$PKG', '', '$FLAG', 0, $BVAL, 1);" 2>/dev/null || true
            fi
        done
    done
}

# 2. Function to inject XML keys directly into Dialer shared_prefs XML files (Hard Overrides)
inject_shared_pref() {
    KEY="$1"
    VAL="$2"
    
    PREF_FILES="/data/data/com.google.android.dialer/shared_prefs/dialer_phenotype_flags.xml /data/data/com.google.android.dialer/shared_prefs/com.google.android.dialer_preferences.xml /data/data/com.google.android.dialer/shared_prefs/phenotype_flags.xml /data/user_de/0/com.google.android.dialer/shared_prefs/dialer_phenotype_flags.xml"

    for FILE in $PREF_FILES; do
        DIR="${FILE%/*}"
        if [ -d "$DIR" ]; then
            if [ ! -f "$FILE" ]; then
                echo '<?xml version="1.0" encoding="utf-8" standalone="yes"?>' > "$FILE"
                echo '<map>' >> "$FILE"
                echo '</map>' >> "$FILE"
                chmod 0660 "$FILE" 2>/dev/null
            fi
            sed -i "/name=\"$KEY\"/d" "$FILE" 2>/dev/null || true
            sed -i "s|</map>|    <boolean name=\"$KEY\" value=\"$VAL\" />\n</map>|" "$FILE" 2>/dev/null || true
        fi
    done
}

# 3. Function to lock down Phenotype database with SQLite triggers
lockdown_db() {
    for DB in $DB_PATHS; do
        if [ -f "$DB" -a -n "$SQLITE_BIN" ]; then
            "$SQLITE_BIN" "$DB" "CREATE TRIGGER IF NOT EXISTS prevent_dialer_flag_override_del BEFORE DELETE ON FlagOverrides WHEN OLD.packageName LIKE 'com.google.android.dialer%' BEGIN SELECT RAISE(IGNORE); END;" 2>/dev/null || true
        fi
    done
}

patch_all_microhooks() {
    # 1. Patch Phenotype Flags (Numeric)
    for flag in 45624401 45628184 45628185 45633861 45645737 45667116 45667117 45667118 45740943 45748547 45664158 45727673 45661436 45684622 45728331 45731943 45684804 45629794 45684179 45722860 45667177 45676586 45413174 45417169 45665235 45408594 45676588 45676587 45676589; do
        patch_flag "$flag" true
    done
    patch_flag "45730953" false

    # 2. Patch Phenotype Flags (Named Strings)
    for flag in G__enable_call_screen G__enable_call_screen_transcript G__enable_auto_call_screening G__enable_manual_call_screen G__enable_hold_for_me G__enable_direct_my_call G__bypass_country_check G__force_call_screen_enabled G__enable_call_recording G__use_call_recording_geofence_overrides G__force_within_call_recording_geofence_value G__force_within_crosby_geofence_value G__enable_atlas_call_screen G__enable_beesly_call_screen G__enable_dobby_call_screen; do
        patch_flag "$flag" true
    done

    # AICore & PSI
    if [ -n "$SQLITE_BIN" ]; then
        for DB in $DB_PATHS; do
            if [ -f "$DB" ]; then
                "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.apps.pixel.psi' AND name='psi_enable_apps';" 2>/dev/null || true
                "$SQLITE_BIN" "$DB" "INSERT OR REPLACE INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.apps.pixel.psi', '', 'psi_enable_apps', 0, 1, 1);" 2>/dev/null || true
                "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.apps.miphone.aiai.nowplaying' AND name='now_playing_notification_history_enabled';" 2>/dev/null || true
                "$SQLITE_BIN" "$DB" "INSERT OR REPLACE INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.apps.miphone.aiai.nowplaying', '', 'now_playing_notification_history_enabled', 0, 1, 1);" 2>/dev/null || true
            fi
        done
    fi

    # 3. Inject Directly into Shared Preferences XML files (Hard Overrides)
    for pref_key in G__enable_call_screen G__enable_call_screen_transcript G__enable_auto_call_screening G__enable_manual_call_screen G__enable_hold_for_me G__enable_direct_my_call G__bypass_country_check G__force_call_screen_enabled call_screening_enabled key_call_screen_enabled key_audio_recording_enabled enable_call_recording; do
        inject_shared_pref "$pref_key" "true"
    done

    # 4. Apply Database Trigger Lockdown
    lockdown_db
}

patch_all_microhooks

# Clean Phenotype Cache
rm -rf /data/data/com.google.android.dialer/files/phenotype/* 2>/dev/null
rm -rf /data/user_de/0/com.google.android.dialer/files/phenotype/* 2>/dev/null

if [ "$1" = "boot" ] || [ "$SERVICE_BOOT" = "1" ]; then
    am force-stop com.google.android.dialer 2>/dev/null || true
    am force-stop com.google.android.gms 2>/dev/null || true
    am force-stop com.google.android.aicore 2>/dev/null || true
    am force-stop com.google.android.apps.pixel.psi 2>/dev/null || true
fi

echo "ACTIVE|35|48" > "$STATUS_FILE"
echo "Microhooks & SharedPrefs Phenotype flags successfully patched."
