#!/system/bin/sh
# Phenotype Microhooks Flag Patcher
MODDIR=${0%/*}
. $MODDIR/vars.sh 2>/dev/null
. $MODDIR/utils.sh 2>/dev/null

patch_all_microhooks() {
    echo "- Patching Phenotype microhook flags..." >> $logfile
    bool_patch "com.google.android.dialer.directboot" 1 45624401 45628184 45628185 45633861 45645737 45667116 45667117 45667118 45740943 45748547 45664158 45727673 45661436 45684622 45728331 45731943 45684804 45629794 45684179 45722860 45667177 45676586 45413174 45417169 45665235 45408594
    bool_patch "com.google.android.dialer.directboot" 0 45730953
    bool_patch "com.google.android.dialer" 1 G__enable_call_recording G__use_call_recording_geofence_overrides G__force_within_call_recording_geofence_value G__force_within_crosby_geofence_value
    bool_patch "com.google.android.apps.pixel.psi" 1 psi_enable_apps
    bool_patch "com.google.android.apps.miphone.aiai.nowplaying" 1 now_playing_notification_history_enabled
}

patch_all_microhooks

