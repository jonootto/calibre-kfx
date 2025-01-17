FROM ghcr.io/linuxserver/baseimage-kasmvnc:ubuntunoble

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CALIBRE_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

ENV \
  CUSTOM_PORT="8080" \
  CUSTOM_HTTPS_PORT="8181" \
  TITLE="Calibre" \
  QTWEBENGINE_DISABLE_SANDBOX="1"
  

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /kclient/public/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/calibre-icon.png && \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    dbus \
    fcitx-rime \
    fonts-wqy-microhei \
    libnss3 \
    libopengl0 \
    libqpdf29t64 \
    libxkbcommon-x11-0 \
    libxcb-cursor0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render-util0 \
    libxcb-xinerama0 \
    poppler-utils \
    python3 \
    python3-xdg \
    ttf-wqy-zenhei \
    wget \
    ca-certificates \
    xz-utils  \
    speech-dispatcher  \
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
    apt-transport-https \
    # calibre 7
    libxcb-cursor0 \
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
    apt-transport-https \
    # calibre 7
    libxcb-cursor0 &&\
  echo "**** install calibre ****" && \
  mkdir -p \
    /opt/calibre && \
  if [ -z ${CALIBRE_RELEASE+x} ]; then \
    CALIBRE_RELEASE=$(curl -sX GET "https://api.github.com/repos/kovidgoyal/calibre/releases/latest" \
    | jq -r .tag_name); \
  fi && \
  CALIBRE_VERSION="$(echo ${CALIBRE_RELEASE} | cut -c2-)" && \
  CALIBRE_URL="https://download.calibre-ebook.com/${CALIBRE_VERSION}/calibre-${CALIBRE_VERSION}-x86_64.txz" && \
  curl -o \
    /tmp/calibre-tarball.txz -L \
    "$CALIBRE_URL" && \
  tar xvf /tmp/calibre-tarball.txz -C \
    /opt/calibre && \
  /opt/calibre/calibre_postinstall && \
  dbus-uuidgen > /etc/machine-id && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files


    
RUN dpkg --add-architecture i386 \
    && mkdir -pm755 /etc/apt/keyrings \
    && wget -O - https://dl.winehq.org/wine-builds/winehq.key | sudo gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -\
    && wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources \
    && apt update \
    && apt install -y --no-install-recommends winbind winehq-staging \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /home/calibre

ENV \
  HOME=/home/calibre \
  XDG_RUNTIME_DIR=/home/calibre

COPY kp3.reg /home/calibre/kp3.reg
RUN cd /home/calibre/ && curl -s -O https://d2bzeorukaqrvt.cloudfront.net/KindlePreviewerInstaller.exe \
    && DISPLAY=:0 WINEARCH=win64 WINEDEBUG=-all wine KindlePreviewerInstaller.exe /S \
    && cat kp3.reg >> /home/calibre/.wine/user.reg && rm *.exe && rm kp3.reg \
    && curl -s -O https://plugins.calibre-ebook.com/272407.zip \
    && calibre-customize -a 272407.zip \
    && curl -s -O https://plugins.calibre-ebook.com/291290.zip \
    && calibre-customize -a 291290.zip \
    && rm *.zip