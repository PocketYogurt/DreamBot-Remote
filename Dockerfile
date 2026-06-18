FROM lscr.io/linuxserver/webtop:ubuntu-xfce

# Eclipse Temurin 11 (DreamBot's recommended JRE) + curl for downloading the launcher
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        gpg \
        curl \
        procps && \
    wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor -o /usr/share/keyrings/adoptium.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" > /etc/apt/sources.list.d/adoptium.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends temurin-11-jre && \
    rm -rf /var/lib/apt/lists/* && \
    update-alternatives --set java /usr/lib/jvm/temurin-11-jre-amd64/bin/java

# DreamBot launcher, placed in /defaults so it gets copied into /config on first boot
RUN mkdir -p /defaults/DreamBot && \
    curl -L -o /defaults/DreamBot/Launcher.jar https://dreambot.org/DBLauncher.jar

# Autostart entry, also via /defaults so it merges in on first boot
RUN mkdir -p /defaults/.config/autostart
COPY dreambot.desktop /defaults/.config/autostart/dreambot.desktop

# Desktop shortcut for manually relaunching DreamBot
RUN mkdir -p /defaults/Desktop
COPY start-dreambot.desktop /defaults/Desktop/start-dreambot.desktop

# Crash-protection watchdog
COPY watchdog.sh /watchdog.sh
RUN chmod +x /watchdog.sh

# Belt-and-braces init script: runs on every container start (any LinuxServer
# image executes everything in /custom-cont-init.d before the desktop starts)
# and makes sure the launcher + autostart file exist and are owned correctly,
# regardless of what state the mounted volume was already in. Also starts
# the watchdog if CRASH_PROTECTION=true.
RUN mkdir -p /custom-cont-init.d
COPY ensure-dreambot.sh /custom-cont-init.d/ensure-dreambot.sh
RUN chmod +x /custom-cont-init.d/ensure-dreambot.sh
