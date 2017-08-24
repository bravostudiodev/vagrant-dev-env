#!/bin/sh
#=========================================================

set -ex

APP_LANG="en_US.UTF-8"
APP_LANGUAGE="en_US:en"
APP_LC_ALL="en_US.UTF-8"

cat > /etc/apt/sources.list << EOF
deb http://archive.ubuntu.com/ubuntu xenial main universe
deb http://archive.ubuntu.com/ubuntu xenial-updates main universe
deb http://security.ubuntu.com/ubuntu xenial-security main universe
EOF
apt-get update -qqy
apt-get install -qqy --no-install-recommends \
    apt-utils \
    upstart

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
    xorg

mkdir -p /tmp/.X11-unix /run/dbus
chmod -R a+rwx /tmp/.X11-unix /run/dbus
su -l vagrant -c "touch /home/vagrant/.Xmodmap /home/vagrant/.Xauthority && mkdir -p /home/vagrant/.fluxbox && echo background: unset >> /home/vagrant/.fluxbox/overlay"

echo "Google Chrome..."
CHROME_VERSION="google-chrome-stable"
wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list
apt-get update -qqy
apt-get install -qqy ${CHROME_VERSION:-google-chrome-stable}

echo "Chrome webdriver..."
CHROME_DRIVER_VERSION=2.29
wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/${CHROME_DRIVER_VERSION}/chromedriver_linux64.zip
mkdir -p /usr/local/bin
unzip /tmp/chromedriver_linux64.zip -d /usr/local/bin
rm /tmp/chromedriver_linux64.zip
mv /usr/local/bin/chromedriver /usr/local/bin/chromedriver-${CHROME_DRIVER_VERSION}
chmod 755 /usr/local/bin/chromedriver-${CHROME_DRIVER_VERSION}
ln -fs /usr/local/bin/chromedriver-${CHROME_DRIVER_VERSION} /usr/local/bin/chromedriver

mv /usr/bin/google-chrome /usr/bin/google-chrome-with-sandbox
echo '#!/usr/bin/env bash\necho $0 $@>>google-chrome.log\nexec -a "$0" "/usr/bin/google-chrome-with-sandbox" --no-sandbox "$@" 2>&1 | tee ~/google-chrome-exec.log'> /usr/bin/google-chrome-no-sandbox
chmod a+x /usr/bin/google-chrome-no-sandbox
ln -s /usr/bin/google-chrome-no-sandbox /usr/bin/google-chrome
mv /opt/google/chrome/google-chrome /opt/google/chrome/google-chrome-with-sandbox
echo '#!/usr/bin/env bash\necho $0 $@>>google-chrome-opt.log\nexec -a "$0" "$0-with-sandbox" --no-sandbox "$@" 2>&1 | tee ~/google-chrome-opt-exec.log '> /opt/google/chrome/google-chrome
chmod a+x /opt/google/chrome/google-chrome
sed -e "s|^\( *\)\([[]submenu[]] [(]Applications[)] {}.*\)$|\1[exec] (Google Chrome) {/opt/google/chrome/google-chrome} </opt/google/chrome/product_logo_32.xpm>\n\1\2|" -i /etc/X11/fluxbox/fluxbox-menu

echo "Firefox..."
FIREFOX_VERSION=53.0
apt-get install -qqy --no-install-recommends firefox
wget --no-verbose -O /tmp/firefox.tar.bz2 https://download-installer.cdn.mozilla.net/pub/firefox/releases/${FIREFOX_VERSION}/linux-x86_64/en-US/firefox-${FIREFOX_VERSION}.tar.bz2
apt-get -y purge firefox
rm -rf /opt/firefox
tar -C /opt -xjf /tmp/firefox.tar.bz2
rm /tmp/firefox.tar.bz2
ln -fs /opt/firefox/firefox /usr/local/bin/firefox-${FIREFOX_VERSION}
ln -fs /usr/local/bin/firefox-${FIREFOX_VERSION} /usr/local/bin/firefox
update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/local/bin/firefox 40
sed -e "s|^\( *\)\([[]submenu[]] [(]Applications[)] {}.*\)$|\1[exec] (Firefox) {/usr/local/bin/firefox} </opt/firefox/browser/chrome/icons/default/default48.png>\n\1\2|" -i /etc/X11/fluxbox/fluxbox-menu

echo "GeckoDriver..."
GECKODRIVER_VERSION=0.16.1
wget --no-verbose -O /tmp/geckodriver.tar.gz https://github.com/mozilla/geckodriver/releases/download/v${GECKODRIVER_VERSION}/geckodriver-v${GECKODRIVER_VERSION}-linux64.tar.gz
mkdir -p /usr/local/bin
tar -C /usr/local/bin -zxf /tmp/geckodriver.tar.gz
rm /tmp/geckodriver.tar.gz
mv /usr/local/bin/geckodriver /usr/local/bin/geckodriver-${GECKODRIVER_VERSION}
chmod 755 /usr/local/bin/geckodriver-${GECKODRIVER_VERSION}
ln -fs geckodriver-${GECKODRIVER_VERSION} /usr/local/bin/geckodriver

cat >> /etc/profile << EOF
export DBUS_SESSION_BUS_ADDRESS=/dev/null
EOF

apt-get install -qqy --no-install-recommends \
    rungetty \
    vim

echo "Set autologin for the Vagrant user..."
# sed -i '$ d' /etc/init/tty1.conf
# echo "exec /sbin/rungetty --autologin vagrant tty1" >> /etc/init/tty1.conf
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat > /etc/systemd/system/getty@tty1.service.d/override.conf << EOF
[Service]
ExecStart=
ExecStart=-/sbin/rungetty --autologin vagrant tty1
Type=idle
EOF

echo -n "Start X on login..."
su -l vagrant -c "touch /home/vagrant/.profile && echo \"[ ! -e '/tmp/.X0-lock' ] && startx \" >> /home/vagrant/.profile"

GRADLE_VERSION=3.4.1
wget --no-verbose -O /tmp/gradle-bin.zip https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip
mkdir -p /opt/gradle
unzip /tmp/gradle-bin.zip -d /opt/gradle
rm /tmp/gradle-bin.zip
ln -fs /opt/gradle/gradle-${GRADLE_VERSION}/bin/gradle /usr/local/bin/gradle-${GRADLE_VERSION}
ln -fs gradle-${GRADLE_VERSION} /usr/local/bin/gradle

SELENIUM_VERSION_BASE=3.5
SELENIUM_VERSION=3.5.2
SELENIUM_URLPATH=${SELENIUM_VERSION_BASE}/selenium-server-standalone-${SELENIUM_VERSION}.jar
mkdir -p /opt/selenium
wget --no-verbose -O /opt/selenium/selenium-server-standalone-${SELENIUM_VERSION}.jar "https://selenium-release.storage.googleapis.com/${SELENIUM_URLPATH}"
chmod a+r /opt/selenium/selenium-server-standalone-${SELENIUM_VERSION}.jar
ln -fs selenium-server-standalone-${SELENIUM_VERSION}.jar /opt/selenium/selenium-server-standalone.jar

echo -n "Install startup scripts..."
cat > /etc/X11/Xsession.d/9999-common_start <<EOF
#!/bin/sh
java -jar /opt/selenium/selenium-server-standalone.jar &
xterm &
EOF
chmod a+x /etc/X11/Xsession.d/9999-common_start

echo -n "Add host alias..."
echo "192.168.33.1 host" >> /etc/hosts

echo -n "Cleanup..."
rm -rf /var/lib/apt/lists/* /var/cache/apt/*
