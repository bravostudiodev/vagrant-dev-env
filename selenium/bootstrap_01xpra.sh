#!/bin/sh

set -ex

export APP_SCREEN_WIDTH=1360
export APP_SCREEN_HEIGHT=1020

cat >> /etc/profile << EOF
export SCREEN_WIDTH=${APP_SCREEN_WIDTH}
export SCREEN_HEIGHT=${APP_SCREEN_HEIGHT}
EOF

apt-get update -qqy
apt-get install -qqy --no-install-recommends \
    dbus-x11 \
    fluxbox \
    fonts-ipafont-gothic \
    mesa-utils \
    python-dbus \
    python-lzo \
    python-netifaces \
    python-opengl \
    python-rencode \
    x11-apps \
    xauth \
    xfonts-100dpi \
    xfonts-75dpi \
    xfonts-cyrillic \
    xfonts-scalable \
    xinit \
    xorg \
    xpra \
    xserver-xorg-input-all \
    xserver-xorg-input-void \
    xserver-xorg-video-all \
    xserver-xorg-video-dummy \
    xterm

python -m pip install --upgrade pip
python -m pip install --upgrade python-uinput
touch /etc/modules
chown root:root /etc/modules
chmod 644 /etc/modules
echo uinput>> /etc/modules
cat /etc/modules

sed -e "s/^\( *\)\(Virtual.*\)$/\1#\2\n\1Virtual ${APP_SCREEN_WIDTH} ${APP_SCREEN_HEIGHT}/" -i /etc/xpra/xorg.conf

systemctl disable xpra

apt-get clean
rm -rf /var/lib/apt/lists/* /var/cache/apt/* || true
