#!/bin/bash

osascript <<'APPLESCRIPT'
tell application "Finder"
    if (count of windows) = 0 then make new Finder window
    activate
end tell
APPLESCRIPT

# Small delay to ensure window is created
#sleep 0.1

# Focus the new/recent Finder window via yabai
#yabai -m window --focus recent

