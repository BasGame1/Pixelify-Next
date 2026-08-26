systemize_velvet() {
    VELVET_DIR="$(get_pkg_app_dir "com.google.android.googlequicksearchbox")"
    if [ -n "$VELVET_DIR" -a -d "$VELVET_DIR" ]; then
        ui_print "- Making Google a system app"
        log " - Making Google a system app from $VELVET_DIR"
        mkdir -p $MODPATH/system/product/priv-app/Velvet 2>/dev/null
        cp -r "$VELVET_DIR/." $MODPATH/system/product/priv-app/Velvet 2>/dev/null || true
        [ -f $MODPATH/system/product/priv-app/Velvet/base.apk ] && mv $MODPATH/system/product/priv-app/Velvet/base.apk $MODPATH/system/product/priv-app/Velvet/Velvet.apk 2>/dev/null || true
        rm -rf $MODPATH/system/product/priv-app/Velvet/oat 2>/dev/null || true
    fi
}
