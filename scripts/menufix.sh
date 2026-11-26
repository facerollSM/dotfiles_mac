#!/bin/bash

defaults write NSGlobalDomain _HIHideMenuBar -bool false
defaults write .GlobalPreferences _HIHideMenuBar -bool false
defaults write NSGlobalDomain AppleMenuBarVisibleInFullscreen -bool true
defaults write .GlobalPreferences AppleMenuBarVisibleInFullscreen -bool true
defaults write com.apple.universalaccess reduceTransparency -bool true

killall cfprefsd 2>/dev/null
killall -KILL MenuBarAgent 2>/dev/null
killall -KILL ControlCenter 2>/dev/null
killall -KILL ControlCenterHelper 2>/dev/null
killall -KILL SystemUIServer 2>/dev/null
killall -KILL Dock 2>/dev/null
killall -KILL WindowManager 2>/dev/null

sleep 1
pmset displaysleepnow
