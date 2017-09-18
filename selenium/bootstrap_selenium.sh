#!/bin/sh

set -ex

APP_LANG="en_US.UTF-8"
APP_LANGUAGE="en_US:en"
APP_LC_ALL="en_US.UTF-8"
APP_SCREEN_WIDTH=1360
APP_SCREEN_HEIGHT=1020

DEBIAN_FRONTEND=noninteractive
DEBCONF_NONINTERACTIVE_SEEN=true
TERM=linux

cat > /etc/apt/sources.list << EOF
deb http://archive.ubuntu.com/ubuntu xenial main universe
deb http://archive.ubuntu.com/ubuntu xenial-updates main universe
deb http://security.ubuntu.com/ubuntu xenial-security main universe
EOF
echo "deb http://winswitch.org/ xenial main" > /etc/apt/sources.list.d/winswitch.list
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
apt-key adv --fetch-keys http://winswitch.org/gpg.asc
# https://www.google.com/linuxrepositories/
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1397BC53640DB551 # apt-key adv --fetch-keys http://dl-ssl.google.com/linux/linux_signing_key.pub
apt-get update -qqy
apt-get install -qqy --no-install-recommends \
    apt-utils \
    upstart

apt-cache show *google-chrome-stable*

apt-get install -qqy --no-install-recommends locales
locale-gen --purge "${APP_LANG}"
update-locale LANG="${APP_LANG}" LANGUAGE="${APP_LANGUAGE}" LC_ALL="${APP_LC_ALL}"
dpkg-reconfigure --frontend noninteractive locales
apt-get install -qqy --no-install-recommends language-pack-en tzdata
echo "${TZ}" > /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

cat >> /etc/profile << EOF
export LANG=${APP_LANG}
export LANGUAGE=${APP_LANGUAGE}
export LC_ALL=${APP_LC_ALL}
export SCREEN_WIDTH=${APP_SCREEN_WIDTH}
export SCREEN_HEIGHT=${APP_SCREEN_HEIGHT}
EOF

apt-get install -qqy --no-install-recommends \
    bzip2 \
    curl \
    ca-certificates \
    psmisc \
    openjdk-8-jre-headless \
    unzip \
    wget

sed -e 's/securerandom\.source=file:\/dev\/random/securerandom\.source=file:\/dev\/urandom/' \
 -i /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/java.security

apt-get install -qqy --no-install-recommends \
    dbus-x11 \
    fluxbox \
    fonts-ipafont-gothic \
    mesa-utils \
    python-dbus \
    python-lzo \
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

sed -e "s/^\( *\)\(Virtual.*\)$/\1#\2\n\1Virtual ${APP_SCREEN_WIDTH} ${APP_SCREEN_HEIGHT}/" -i /etc/xpra/xorg.conf

systemctl disable xpra

echo "Google Chrome..."
# https://www.ubuntuupdates.org/pm/google-chrome-stable
# CHROME_VERSION="google-chrome-stable=61.0.3163.79-1"
# Google removes old versions from repositories, it is only possible to install stable beta or unstable versions
CHROME_VERSION="google-chrome-stable"
rm -f /opt/google/chrome/google-chrome
apt-get install -qqy --no-install-recommends ${CHROME_VERSION:-google-chrome-stable}
mv -f /opt/google/chrome/google-chrome /opt/google/chrome/google-chrome-original
cat > /usr/bin/google-chrome-no-sandbox << "EOF"
#!/usr/bin/env bash
echo $0 $@>>google-chrome-opt.log
exec -a "$0" "/opt/google/chrome/google-chrome-original" --no-sandbox "$@" 2>&1 | tee ~/google-chrome-no-sandbox-exec.log
EOF
chmod a+x /usr/bin/google-chrome-no-sandbox
ln -fs /usr/bin/google-chrome-no-sandbox /opt/google/chrome/google-chrome

update-alternatives --install /usr/bin/google-chrome google-chrome /usr/bin/google-chrome-no-sandbox 400

echo "Chrome webdriver..."
CHROME_DRIVER_VERSION=2.32
wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/${CHROME_DRIVER_VERSION}/chromedriver_linux64.zip
mkdir -p /usr/local/bin
unzip -o /tmp/chromedriver_linux64.zip -d /usr/local/bin
rm /tmp/chromedriver_linux64.zip
mv /usr/local/bin/chromedriver /usr/local/bin/chromedriver-${CHROME_DRIVER_VERSION}
chmod 755 /usr/local/bin/chromedriver-${CHROME_DRIVER_VERSION}
ln -fs /usr/local/bin/chromedriver-${CHROME_DRIVER_VERSION} /usr/local/bin/chromedriver

echo "Firefox..."
FIREFOX_VERSION=56.0b9
apt-get install -qqy --no-install-recommends firefox
wget --no-verbose -O /tmp/firefox.tar.bz2 https://download-installer.cdn.mozilla.net/pub/firefox/releases/${FIREFOX_VERSION}/linux-x86_64/en-US/firefox-${FIREFOX_VERSION}.tar.bz2
apt-get -y purge firefox
rm -rf /opt/firefox
tar -C /opt -xjf /tmp/firefox.tar.bz2
rm /tmp/firefox.tar.bz2
ln -fs /opt/firefox/firefox /usr/local/bin/firefox-${FIREFOX_VERSION}
ln -fs /usr/local/bin/firefox-${FIREFOX_VERSION} /usr/local/bin/firefox
update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/local/bin/firefox 40

echo "GeckoDriver..."
GECKODRIVER_VERSION=0.18.0
wget --no-verbose -O /tmp/geckodriver.tar.gz https://github.com/mozilla/geckodriver/releases/download/v${GECKODRIVER_VERSION}/geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz
mkdir -p /usr/local/bin
tar -C /usr/local/bin -zxf /tmp/geckodriver.tar.gz
rm /tmp/geckodriver.tar.gz
mv /usr/local/bin/geckodriver /usr/local/bin/geckodriver-${GECKODRIVER_VERSION}
chmod 755 /usr/local/bin/geckodriver-${GECKODRIVER_VERSION}
ln -fs geckodriver-${GECKODRIVER_VERSION} /usr/local/bin/geckodriver

cat > /etc/X11/fluxbox/fluxbox.menu-user << EOF
[begin] (fluxbox)
[exec] (Google Chrome) {/opt/google/chrome/google-chrome} </opt/google/chrome/product_logo_32.xpm>
[exec] (Firefox) {/usr/local/bin/firefox} </opt/firefox/browser/chrome/icons/default/default48.png>
[include] (/etc/X11/fluxbox/fluxbox-menu)
[end]
EOF

# cat >> /etc/profile << EOF
# export DBUS_SESSION_BUS_ADDRESS=/dev/null
# EOF

apt-get install -qqy --no-install-recommends \
    procps \
    rungetty \
    vim

# GRADLE_VERSION=3.4.1
# wget --no-verbose -O /tmp/gradle-bin.zip https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
# mkdir -p /opt/gradle
# unzip -o /tmp/gradle-bin.zip -d /opt/gradle
# rm /tmp/gradle-bin.zip
# ln -fs /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle /usr/local/bin/gradle-${GRADLE_VERSION}
# ln -fs gradle-${GRADLE_VERSION} /usr/local/bin/gradle

echo "Selenium..."
SELENIUM_VERSION_BASE=3.5
SELENIUM_VERSION=3.5.3
SELENIUM_URLPATH=${SELENIUM_VERSION_BASE}/selenium-server-standalone-${SELENIUM_VERSION}.jar
mkdir -p /opt/selenium
wget --no-verbose -O /opt/selenium/selenium-server-standalone-${SELENIUM_VERSION}.jar "https://selenium-release.storage.googleapis.com/${SELENIUM_URLPATH}"
chmod a+r /opt/selenium/selenium-server-standalone-${SELENIUM_VERSION}.jar
ln -fs selenium-server-standalone-${SELENIUM_VERSION}.jar /opt/selenium/selenium-server-standalone.jar

echo "Selenium Bravo Servlet..."
BRAVOSERVLET_VERSION=2.0
mkdir -p /opt/selenium
wget --no-verbose -O /opt/selenium/selenium-bravo-servlet-${BRAVOSERVLET_VERSION}.jar \
 https://github.com/bravostudiodev/bravo-grid/releases/download/${BRAVOSERVLET_VERSION}/selenium-bravo-servlet-${BRAVOSERVLET_VERSION}-deps.jar
ln -fs selenium-bravo-servlet-${BRAVOSERVLET_VERSION}.jar /opt/selenium/selenium-bravo-servlet.jar

echo -n "Cleanup..."
rm -rf /var/lib/apt/lists/* /var/cache/apt/*
