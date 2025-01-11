FROM lscr.io/linuxserver/calibre:latest
ARG WINE_BRANCH="stable"

RUN apt update && \
    apt install -y --no-install-recommends \
    # Calibre deps
    ca-certificates \
    curl \
    gnupg2 \
    xz-utils \
    # QTWebEngine deps
    libxdamage-dev libxrandr-dev libxtst6 \
    # for kindle support
    xvfb \
    libegl1 \
    libopengl0 \
    libxkbcommon-x11-0 \
    libxcomposite-dev \
    # calibre 7
    libxcb-cursor0 \
    && rm -rf /var/lib/apt/lists/*

RUN dpkg --add-architecture i386 \
    && mkdir -pm755 /etc/apt/keyrings \
    && curl -o /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
    && curl -L -o /etc/apt/sources.list.d/winehq-bookworm.sources https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources \
    && apt update \
    && apt install -y --no-install-recommends winbind winehq-${WINE_BRANCH} \
    && rm -rf /var/lib/apt/lists/*



COPY kp3.reg /config/kp3.reg  

RUN cd /config/ && curl -s -O https://d2bzeorukaqrvt.cloudfront.net/KindlePreviewerInstaller.exe \
    && DISPLAY=:0 WINEARCH=win64 WINEDEBUG=-all wine KindlePreviewerInstaller.exe /S \
    && cat kp3.reg >> /config/.wine/user.reg && rm *.exe && rm kp3.reg \
    && curl -s -O https://plugins.calibre-ebook.com/272407.zip \
    && calibre-customize -a 272407.zip \
    && curl -s -O https://plugins.calibre-ebook.com/291290.zip \
    && calibre-customize -a 291290.zip \
    && rm *.zip