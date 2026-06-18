#!/bin/bash
# Watches for DreamBot (launcher or client) and relaunches it if it
# isn't running. Controlled by the CRASH_PROTECTION env var.
#
# DreamBot's own launcher self-updates by re-executing itself as a new
# process, which means there's a brief window where no matching process
# exists even though nothing has actually crashed. To avoid the watchdog
# mistaking that window for a crash, it only relaunches after several
# consecutive checks all come back empty.

if [ "${CRASH_PROTECTION}" != "true" ]; then
    exit 0
fi

# Give the desktop a head start before the watchdog begins checking.
sleep 15

MISSED=0
REQUIRED_MISSES=4   # ~20 seconds of sustained absence before relaunching
CHECK_INTERVAL=5

while true; do
    if pgrep -if "dreambot" > /dev/null; then
        MISSED=0
    else
        MISSED=$((MISSED + 1))
    fi

    if [ "$MISSED" -ge "$REQUIRED_MISSES" ]; then
        DISPLAY=:1.0 java -jar /config/DreamBot/Launcher.jar &
        MISSED=0
        sleep 30   # give it time to start before checking again
    fi

    sleep "$CHECK_INTERVAL"
done
