install_app() {
  local APP_FILENAME="$1"
  local APP_PATH="$MODPATH/files/$APP_FILENAME"

  ui_print " "
  ui_print "***********************************"
  ui_print " Processing: $APP_FILENAME "
  ui_print "***********************************"

  if [ ! -f "$APP_PATH" ]; then
    ui_print "! ERROR: File not found: $APP_PATH"
    return 1
  fi

  local EXTENSION="${APP_FILENAME##*.}"
  if [ "$EXTENSION" = "apk" ]; then
    ui_print "- Installing single APK: $APP_FILENAME"
    pm install -r -d "$APP_PATH"
    
    if [ $? -ne 0 ]; then
      ui_print "! ERROR: Failed to install $APP_FILENAME."
      return 1
    fi
    
    ui_print "- Successfully installed $APP_FILENAME."
    return 0

  elif [ "$EXTENSION" = "apkm" ]; then
    ui_print "- Installing split APKM: $APP_FILENAME"
    local TMP_EXTRACT_DIR="$MODPATH/temp_apks"
    
    ui_print "- Preparing temporary directory..."
    rm -rf "$TMP_EXTRACT_DIR"
    mkdir -p "$TMP_EXTRACT_DIR"

    ui_print "- Extracting $APP_FILENAME..."
    unzip -o "$APP_PATH" -d "$TMP_EXTRACT_DIR" >&2
    if [ $? -ne 0 ]; then
      ui_print "! ERROR: Failed to unzip $APP_FILENAME"
      rm -rf "$TMP_EXTRACT_DIR"
      return 1
    fi

    local APK_FILES=$(find "$TMP_EXTRACT_DIR" -type f -name "*.apk")
    if [ -z "$APK_FILES" ]; then
      ui_print "! ERROR: No .apk files found in $APP_FILENAME."
      rm -rf "$TMP_EXTRACT_DIR"
      return 1
    fi
    
    ui_print "- Creating install session..."
    local SESSION_DATA=$(pm install-create -r)
    local SESSION_ID=$(echo "$SESSION_DATA" | grep -o '[0-9]\+')
    
    if [ -z "$SESSION_ID" ]; then
      ui_print "! ERROR: Failed to create install session."
      rm -rf "$TMP_EXTRACT_DIR"
      return 1
    fi
    ui_print "  Session ID: $SESSION_ID"
    
    for APK in $APK_FILES; do
      local APK_NAME=$(basename "$APK")
      ui_print "- Writing $APK_NAME to session..."
      pm install-write "$SESSION_ID" "$APK_NAME" "$APK"
      if [ $? -ne 0 ]; then
        ui_print "! ERROR: Failed to write $APK_NAME."
        pm install-abandon "$SESSION_ID"
        rm -rf "$TMP_EXTRACT_DIR"
        return 1
      fi
    done
    
    ui_print "- Committing installation..."
    local COMMIT_DATA=$(pm install-commit "$SESSION_ID")
    rm -rf "$TMP_EXTRACT_DIR"
    
    if echo "$COMMIT_DATA" | grep -q "Success"; then
      ui_print "- Successfully installed $APP_FILENAME."
      return 0
    else
      ui_print "! ERROR: Installation failed to commit."
      ui_print "  Details: $COMMIT_DATA"
      return 1
    fi
  
  else
    ui_print "! ERROR: Unknown file type: $APP_FILENAME"
    ui_print "  Only .apk and .apks files are supported."
    return 1
  fi
}
