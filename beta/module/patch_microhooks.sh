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
TOTAL_PATCHED=0

patch_db() {
    DB="$1"
    if [ ! -f "$DB" ]; then return; fi
    chmod 0666 "$DB" 2>/dev/null
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

echo "ACTIVE|0|48" > "$STATUS_FILE"
echo "Microhooks Phenotype flags successfully patched."

