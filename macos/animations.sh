#!/bin/bash
# Schnellere/abgeschaltete macOS-Animationen.
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
defaults write -g NSWindowResizeTime -float 0.001
defaults write com.apple.dock expose-animation-duration -float 0.15
defaults write com.apple.dock launchanim -bool false
defaults write com.apple.dock springboard-show-duration -float 0
defaults write com.apple.dock springboard-hide-duration -float 0
defaults write com.apple.finder DisableAllAnimations -bool true
killall Dock Finder 2>/dev/null || true
echo "Animationen angepasst."
