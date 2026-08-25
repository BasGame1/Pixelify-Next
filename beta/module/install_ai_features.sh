# Ik this is terrible code, this is a poc of the patch system and i will fix it later (if i remember)
patch_ask_photos() {
 patch_flag $ASK_PHOTOS_PACKAGE $ASK_PHOTOS_FLAGS true
}
patch_ask_maps() {
 patch_flag $ASK_MAPS_PACKAGE $ASK_MAPS_FLAGS true
}
patch_rambler() {
 for i in $RAMBLER_FLAGS; do
  patch_flag $RAMBLER_PACKAGE $i true
 done
}
ai_features_menu() {
 log "--AI FEATURES MENU--"
 log "1) Rambler"
 log "2) Ask Photos"
 log "3) Ask Maps"
 log "4) Exit"
}
current_selection_option() {
 log "Current selection: [$1]"
}
check_selection() {
 case $CURRENT_SELECTION in
  1)
   ask_features_menu
   current_selection_option "1) Rambler"
  ;;
  2)
   ask_features_menu
   current_selection_option "2) Ask Photos"
  ;;
  3)
   ask_features_menu
   current_selection_option "3) Ask Maps"
  ;;
  4)
   ask_features_menu
   current_selection_option "4) Exit"
  ;;
  *)
   log "unkown case option: $CURRENT_SELECTION"
   abort "Error with ai features menu, exiting"
 esac
}
install_another_selection() {
 log "$1 patched, install another one?"
 if $VKSEL; then
   log "Showing menu again for installing other"
   ai_installation_menu
   check_selection
 else
   log "Dont install another one apart from $1"
 fi
}
user_make_selection() {
   if $VKSEL; then
    CURRENT_SELECTION=$(( $CURRENT_SELECTION + 1 ))
    if [ $CURRENT_SELECTION -eq 5 ]; then
     CURRENT_SELECTION=1
    fi
    check_selection
   else
    case $CURRENT_SELECTION in
     1)
      log "Rambler selected"
      log "Rambler selected"
      patch_rambler
      install_another_selection "rambler"
     ;;
     2)
      log "Ask photos selected"
      log "Ask photos selected"
      patch_ask_photos
      install_another_selection "ask photos"
     ;;
     3)
      log "Ask maps selected"
      log "Ask maps selected"
      patch_ask_maps
      install_another_selection "ask maps"
     ;;
     4)
      log "Exit menu selected"
      log "exit menu selected"
     ;;
     *)
      log "unkown case option: $CURRENT_SELECTION"
      abort "Error with ai features menu, exiting"
     ;;
    esac
   fi
}


install_ai_features() {
 log ""
 log "Do you want to be shown the ai features menu?"
 log "Rambler, ask photos, ask maps, etc"
 log "    Vol Up += Yes"
 log "    Vol Down += No"
 no_vk "INSTALL_AI_FEATURES"
 if $VKSEL; then
  log "Volumen up selected, showing install ai features menu"
   CURRENT_SELECTION=1
   ai_features_menu
   log " Use VOL+ for next one"
   log " And VOL- for selecting"
   user_make_selection
 else
  log "Volumen down selected, skipping ai features"
 fi
}
