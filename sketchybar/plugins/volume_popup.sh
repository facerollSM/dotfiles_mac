#!/bin/bash
# Lautstärke-Popup: Klick aufs Lautsprecher-Symbol → Schieberegler (+ Geräteauswahl, falls SwitchAudioSource installiert).
# Aufrufe:
#   volume_popup.sh            → Popup umschalten
#   volume_popup.sh close      → Popup schließen
#   volume_popup.sh mute       → Ton an/aus
#   volume_popup.sh out|in N   → Ausgabe-/Eingabegerät Nr. N wählen
# Der Regler selbst ruft dieses Skript mit SENDER=mouse.clicked und PERCENTAGE auf.
source "$CONFIG_DIR/plugins/popup_lib.sh"
SELF="$CONFIG_DIR/plugins/volume_popup.sh"
SAS=/opt/homebrew/bin/SwitchAudioSource

fill() {
  local VOL MUTED
  VOL="$(osascript -e 'output volume of (get volume settings)')"
  MUTED="$(osascript -e 'output muted of (get volume settings)')"

  # Regler
  $SB --add slider volume.p.slider popup.volume 180 \
      --set volume.p.slider slider.percentage="$VOL" \
                            slider.highlight_color=$YELLOW \
                            slider.background.height=6 \
                            slider.background.corner_radius=3 \
                            slider.background.color=0xff504945 \
                            slider.knob=󰝤 slider.knob.font="$FONT:Bold:16.0" \
                            slider.knob.color=$FG \
                            icon.drawing=off label.drawing=off \
                            padding_left=10 padding_right=10 \
                            script="$SELF" \
      --subscribe volume.p.slider mouse.clicked >/dev/null

  if [ "$MUTED" = "true" ]; then
    popup_row volume mute 󰖁 "Ton einschalten" "$SELF mute" $ORANGE
  else
    popup_row volume mute 󰝟 "Stumm schalten" "$SELF mute"
  fi

  # Geräteauswahl (nur mit SwitchAudioSource)
  if [ -x "$SAS" ]; then
    local cur i=0
    popup_row volume hout "" "Ausgabe" "" $GRAY
    cur="$($SAS -c -t output)"
    while IFS= read -r dev; do
      if [ "$dev" = "$cur" ]; then
        popup_row volume o$i 󰄬 "$dev" "" $YELLOW
      else
        popup_row volume o$i 󰓃 "$dev" "$SELF out $i"
      fi
      i=$((i + 1))
    done < <($SAS -a -t output)

    i=0
    popup_row volume hin "" "Eingabe" "" $GRAY
    cur="$($SAS -c -t input)"
    while IFS= read -r dev; do
      if [ "$dev" = "$cur" ]; then
        popup_row volume i$i 󰄬 "$dev" "" $YELLOW
      else
        popup_row volume i$i 󰍬 "$dev" "$SELF in $i"
      fi
      i=$((i + 1))
    done < <($SAS -a -t input)
  fi

  popup_row volume set 󰒓 "Ton-Einstellungen …" \
    "$SELF close; open 'x-apple.systempreferences:com.apple.Sound-Settings.extension'" $GRAY
}

# Regler wurde bewegt/geklickt
if [ "$SENDER" = "mouse.clicked" ] && [ -n "$PERCENTAGE" ]; then
  osascript -e "set volume output volume $PERCENTAGE"
  $SB --set volume.p.slider slider.percentage="$PERCENTAGE"
  exit 0
fi

case "$1" in
  close) popup_close volume ;;
  mute)
    if [ "$(osascript -e 'output muted of (get volume settings)')" = "true" ]; then
      osascript -e 'set volume without output muted'
    else
      osascript -e 'set volume with output muted'
    fi
    popup_close volume
    ;;
  out|in)
    t=$([ "$1" = out ] && echo output || echo input)
    dev="$($SAS -a -t $t | sed -n "$(( $2 + 1 ))p")"
    [ -n "$dev" ] && $SAS -t $t -s "$dev" >/dev/null
    popup_close volume
    ;;
  *) popup_toggle volume fill ;;
esac
