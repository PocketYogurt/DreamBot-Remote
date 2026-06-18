#!/bin/bash
# Ensures the DreamBot launcher and autostart entry exist in /config,
# even if the mounted volume predates this image or was only partially
# initialised. Also starts the crash-protection watchdog if enabled.
# Safe to run on every boot.

mkdir -p /config/DreamBot
if [ ! -f /config/DreamBot/Launcher.jar ]; then
    cp /defaults/DreamBot/Launcher.jar /config/DreamBot/Launcher.jar
fi

mkdir -p /config/.config/autostart
if [ ! -f /config/.config/autostart/dreambot.desktop ]; then
    cp /defaults/.config/autostart/dreambot.desktop /config/.config/autostart/dreambot.desktop
fi

mkdir -p /config/Desktop
if [ ! -f /config/Desktop/start-dreambot.desktop ]; then
    cp /defaults/Desktop/start-dreambot.desktop /config/Desktop/start-dreambot.desktop
fi

chown -R abc:abc /config/DreamBot /config/.config/autostart /config/Desktop/start-dreambot.desktop
chmod +x /config/.config/autostart/dreambot.desktop /config/Desktop/start-dreambot.desktop

if [ "${CRASH_PROTECTION}" = "true" ]; then
    nohup /watchdog.sh > /tmp/watchdog.log 2>&1 &
    disown
fi
