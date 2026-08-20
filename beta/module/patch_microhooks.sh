#!/system/bin/sh
# Phenotype Microhooks Flag Patcher for Dialer, Call Screen & Pixel Features
# Compatible with new Phenotype DB versions (Flags, FlagOverrides, FlagOverride tables)
MODDIR=${0%/*}

SQLITE_BIN=""
if [ -x "$MODDIR/addon/sqlite3" ]; then
    SQLITE_BIN="$MODDIR/addon/sqlite3"
elif command -v sqlite3 >/dev/null 2>&1; then
    SQLITE_BIN="$(command -v sqlite3)"
elif [ -x /system/bin/sqlite3 ]; then
    SQLITE_BIN="/system/bin/sqlite3"
fi

if [ -z "$SQLITE_BIN" ]; then
    echo "Error: sqlite3 binary not found for microhooks patcher"
    exit 1
fi

DB_PATHS="/data/data/com.google.android.gms/databases/phenotype.db /data/user_de/0/com.google.android.gms/databases/phenotype.db /data/data/com.google.android.dialer/databases/phenotype.db /data/user_de/0/com.google.android.dialer/databases/phenotype.db"

STATUS_FILE="$MODDIR/flags_status"
TOTAL_PATCHED=0

patch_db() {
    DB="$1"
    if [ ! -f "$DB" ]; then return; fi
    chmod 0666 "$DB" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45624401';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45624401';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45624401', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45624401', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45624401', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45628184';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45628184';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45628184', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45628184', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45628184', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45628185';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45628185';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45628185', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45628185', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45628185', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45633861';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45633861';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45633861', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45633861', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45633861', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45645737';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45645737';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45645737', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45645737', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45645737', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45667116';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45667116';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45667116', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45667116', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45667116', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45667117';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45667117';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45667117', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45667117', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45667117', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45667118';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45667118';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45667118', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45667118', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45667118', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45740943';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45740943';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45740943', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45740943', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45740943', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45748547';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45748547';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45748547', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45748547', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45748547', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45664158';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45664158';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45664158', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45664158', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45664158', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45727673';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45727673';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45727673', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45727673', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45727673', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45661436';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45661436';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45661436', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45661436', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45661436', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45684622';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45684622';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45684622', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45684622', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45684622', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45728331';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45728331';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45728331', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45728331', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45728331', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45731943';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45731943';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45731943', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45731943', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45731943', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 0 WHERE packageName='com.google.android.dialer.directboot' AND name='45730953';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45730953';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45730953', 0, 0, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45730953', 0, 0, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45730953', 0, 0, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer' AND name='G__enable_call_recording';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer' AND name='G__enable_call_recording';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer', '', 'G__enable_call_recording', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer', '', 'G__enable_call_recording', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer', '', 'G__enable_call_recording', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer' AND name='G__use_call_recording_geofence_overrides';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer' AND name='G__use_call_recording_geofence_overrides';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer', '', 'G__use_call_recording_geofence_overrides', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer', '', 'G__use_call_recording_geofence_overrides', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer', '', 'G__use_call_recording_geofence_overrides', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer' AND name='G__force_within_call_recording_geofence_value';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer' AND name='G__force_within_call_recording_geofence_value';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer', '', 'G__force_within_call_recording_geofence_value', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer', '', 'G__force_within_call_recording_geofence_value', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer', '', 'G__force_within_call_recording_geofence_value', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer' AND name='G__force_within_crosby_geofence_value';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer' AND name='G__force_within_crosby_geofence_value';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer', '', 'G__force_within_crosby_geofence_value', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer', '', 'G__force_within_crosby_geofence_value', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer', '', 'G__force_within_crosby_geofence_value', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45684804';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45684804';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45684804', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45684804', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45684804', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45629794';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45629794';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45629794', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45629794', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45629794', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45684179';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45684179';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45684179', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45684179', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45684179', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45722860';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45722860';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45722860', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45722860', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45722860', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45667177';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45667177';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45667177', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45667177', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45667177', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45676586';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45676586';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45676586', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45676586', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45676586', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45413174';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45413174';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45413174', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45413174', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45413174', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45417169';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45417169';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45417169', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45417169', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45417169', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45665235';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45665235';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45665235', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45665235', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45665235', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45408594';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45408594';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45408594', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45408594', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45408594', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.apps.pixel.psi' AND name='psi_enable_apps';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.apps.pixel.psi' AND name='psi_enable_apps';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.apps.pixel.psi', '', 'psi_enable_apps', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.apps.pixel.psi', '', 'psi_enable_apps', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.apps.pixel.psi', '', 'psi_enable_apps', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.apps.miphone.aiai.nowplaying' AND name='now_playing_notification_history_enabled';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.apps.miphone.aiai.nowplaying' AND name='now_playing_notification_history_enabled';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.apps.miphone.aiai.nowplaying', '', 'now_playing_notification_history_enabled', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.apps.miphone.aiai.nowplaying', '', 'now_playing_notification_history_enabled', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.apps.miphone.aiai.nowplaying', '', 'now_playing_notification_history_enabled', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45676588';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45676588';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45676588', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45676588', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45676588', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45676587';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45676587';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45676587', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45676587', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45676587', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "UPDATE Flags SET boolVal = 1 WHERE packageName='com.google.android.dialer.directboot' AND name='45676589';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "DELETE FROM FlagOverrides WHERE packageName='com.google.android.dialer.directboot' AND name='45676589';" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45676589', 0, 1, 0);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverrides (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45676589', 0, 1, 1);" 2>/dev/null
    "$SQLITE_BIN" "$DB" "INSERT INTO FlagOverride (packageName, user, name, flagType, boolVal, committed) VALUES ('com.google.android.dialer.directboot', '', '45676589', 0, 1, 1);" 2>/dev/null
}

for db in $DB_PATHS; do
    patch_db "$db"
done

rm -rf /data/data/com.google.android.dialer/files/phenotype/* 2>/dev/null
rm -rf /data/user_de/0/com.google.android.dialer/files/phenotype/* 2>/dev/null
am force-stop com.google.android.dialer 2>/dev/null
am force-stop com.google.android.gms 2>/dev/null
am force-stop com.google.android.aicore 2>/dev/null
am force-stop com.google.android.apps.pixel.psi 2>/dev/null

echo "ACTIVE|48|48" > "$STATUS_FILE"
echo "Microhooks Phenotype flags successfully patched."

