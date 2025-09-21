#!/sbin/sh
# Testing for recovery mode
. $MODPATH/variables.sh
print "Testing for recovery mode"
if [ "$(getprop init.svc.zygote)" = 0 ]; then
	if [ "$(test -c /data/adb/modules)" = 0 ]; then
		cp . /data/adb/modules
	else
		cp . /data/adb/ksu/modules
	fi
else
	print "Not in TWRP"
fi 
keytest() {
    print "- Vol Key Test"
    print "    Press a Vol Key:"
    if (timeout 5 /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" >$TMPDIR/events); then
        return 0
    else
        print "   Try again:"
        timeout 5 $MODPATH/tools/keycheck
        local SEL=$?
        [ $SEL -eq 143 ] && abort1 "   Vol key not detected!" || return 1
    fi
}
if keytest; then
	print "   Vol key detected!"
else
	abort1 "   Vol key not detected!"
fi
get_key_press() {
  print "Komodo (Pixel 9 pro xl) to photos and dialer"
  print "  Press Volume UP to ENABLE spoofing."
  print "  Press Volume DOWN to DISABLE spoofing."

  local EVENTS_FILE="/dev/keycheck_events"

  # Primary Method: Use getevent
  if (timeout 5 /system/bin/getevent -lc 1 2>&1 | /system/bin/grep VOLUME | /system/bin/grep " DOWN" > $EVENTS_FILE); then
    if cat $EVENTS_FILE | /system/bin/grep "VOLUME_UP" > /dev/null; then
      echo "UP"
    else
      echo "DOWN"
    fi
  else
    # Fallback Method: Use a bundled keycheck binary
    timeout 5 $MODPATH/addon/keycheck
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
      echo "UP"
    elif [ $exit_code -eq 1 ]; then
      echo "DOWN"
    else
      # Timeout or other error
      echo "NONE"
    fi
  fi
}
CHOICE=$(get_key_press)
SPOOF_ENABLED=0 # Default to disabled

case $CHOICE in
  "UP")
    ui_print "  Volume UP detected."
    SPOOF_ENABLED=1
    ;;
  "DOWN")
    ui_print "  Volume DOWN detected."
    SPOOF_ENABLED=0
    ;;
  "NONE")
    abort "No input detected within 5 seconds."
    ;;
  *)
    abort "An unknown error occurred during key detection."
    ;;
esac

ui_print " "

# --- FINAL ACTION ---
# Now, perform the action based on the SPOOF_ENABLED variable.

if [ $SPOOF_ENABLED -eq 1 ]; then
  ui_print "--> ENABLING Zygisk spoofing."
  ui_print "    Installing configuration file..."
  # We copy the spoof.conf from our ZIP to the installed module directory.
  cp -f $ZIPFILE/spoof.conf $MODDIR/spoof.conf
  set_perm $MODDIR/spoof.conf 0 0 0644
else
  ui_print "--> DISABLING Zygisk spoofing."
  ui_print "    Skipping configuration file installation."
  # By not copying the spoof.conf file, the C++ engine will find no rules
  # and will not apply any hooks. This effectively disables the feature.
fi




