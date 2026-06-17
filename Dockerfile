FROM lscr.io/linuxserver/webtop:ubuntu-xfce

# Java runtime + curl for downloading the launcher
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        default-jre \
        curl && \
    rm -rf /var/lib/apt/lists/*

# DreamBot launcher, placed in /defaults so it gets copied into /config on first boot
RUN mkdir -p /defaults/DreamBot && \
    curl -L -o /defaults/DreamBot/Launcher.jar https://dreambot.org/DBLauncher.jar

# Autostart entry, also via /defaults so it merges in on first boot
RUN mkdir -p /defaults/.config/autostart
COPY dreambot.desktop /defaults/.config/autostart/dreambot.desktop

# Belt-and-braces init script: runs on every container start (any LinuxServer
# image executes everything in /custom-cont-init.d before the desktop starts)
# and makes sure the launcher + autostart file exist and are owned correctly,
# regardless of what state the mounted volume was already in.
RUN mkdir -p /custom-cont-init.d
COPY ensure-dreambot.sh /custom-cont-init.d/ensure-dreambot.sh
RUN chmod +x /custom-cont-init.d/ensure-dreambot.sh
