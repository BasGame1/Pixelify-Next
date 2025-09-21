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
        timeout 5 $MODPATH/addon/keycheck
        local SEL=$?
        [ $SEL -eq 143 ] && abort1 "   Vol key not detected!" || return 1
    fi
}
if keytest; then
	print "   Vol key detected!"
else
	abort1 "   Vol key not detected!"
fi
print "Do you want spoof?"






