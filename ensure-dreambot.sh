#!/bin/bash
# Ensures the DreamBot launcher and autostart entry exist in /config,
# even if the mounted volume predates this image or was only partially
# initialised. Safe to run on every boot.

mkdir -p /config/DreamBot
if [ ! -f /config/DreamBot/Launcher.jar ]; then
    cp /defaults/DreamBot/Launcher.jar /config/DreamBot/Launcher.jar
fi

mkdir -p /config/.config/autostart
if [ ! -f /config/.config/autostart/dreambot.desktop ]; then
    cp /defaults/.config/autostart/dreambot.desktop /config/.config/autostart/dreambot.desktop
fi

chown -R abc:abc /config/DreamBot /config/.config/autostart
chmod +x /config/.config/autostart/dreambot.desktop
