#!/bin/bash
# Maus verlässt Knopf + Popup → Popup schließen
[ "$SENDER" = "mouse.exited.global" ] && { source "$CONFIG_DIR/plugins/popup_lib.sh"; popup_close power; }
