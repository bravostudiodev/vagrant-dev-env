#!/bin/sh

set -ex

DEBIAN_FRONTEND=noninteractive
DEBCONF_NONINTERACTIVE_SEEN=true
TERM=linux

apt-get update -qqy

echo "Google Chrome..."
CHROME_VERSION="google-chrome-stable"
rm -f /opt/google/chrome/google-chrome
apt-get install --reinstall -qqy --no-install-recommends ${CHROME_VERSION:-google-chrome-stable}
mv -f /opt/google/chrome/google-chrome /opt/google/chrome/google-chrome-original

echo "Chrome webdriver..."
CHROME_DRIVER_VERSION=$(curl -L -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE)
wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/${CHROME_DRIVER_VERSION}/chromedriver_linux64.zip
mkdir -p /usr/local/bin
unzip -o /tmp/chromedriver_linux64.zip -d /usr/local/bin
rm /tmp/chromedriver_linux64.zip
chmod 755 /usr/local/bin/chromedriver

echo "Firefox..."
FIREFOX_VERSION=57.0b8
apt-get install --reinstall -qqy --no-install-recommends firefox
wget --no-verbose -O /tmp/firefox.tar.bz2 https://download-installer.cdn.mozilla.net/pub/firefox/releases/${FIREFOX_VERSION}/linux-x86_64/en-US/firefox-${FIREFOX_VERSION}.tar.bz2
apt-get -y purge firefox
rm -rf /opt/firefox
tar -C /opt -xjf /tmp/firefox.tar.bz2
rm /tmp/firefox.tar.bz2
ln -fs /opt/firefox/firefox /usr/local/bin/firefox

echo "GeckoDriver..."
GECKODRIVER_VERSION=$(curl -L -s -H "Accept: application/json" https://github.com/mozilla/geckodriver/releases/latest | jq -r ".tag_name")
wget --no-verbose -O /tmp/geckodriver.tar.gz https://github.com/mozilla/geckodriver/releases/download/${GECKODRIVER_VERSION}/geckodriver-${GECKODRIVER_VERSION}-linux64.tar.gz
mkdir -p /usr/local/bin
tar -C /usr/local/bin -zxf /tmp/geckodriver.tar.gz
rm /tmp/geckodriver.tar.gz
chmod 755 /usr/local/bin/geckodriver

cat > /etc/X11/fluxbox/fluxbox.menu-user << EOF
[begin] (fluxbox)
[exec] (Google Chrome) {/opt/google/chrome/google-chrome} </opt/google/chrome/product_logo_32.xpm>
[exec] (Firefox) {/usr/local/bin/firefox} </opt/firefox/browser/chrome/icons/default/default48.png>
[include] (/etc/X11/fluxbox/fluxbox-menu)
[end]
EOF

echo "Selenium..."
SELENIUM_VERSION=$(curl -L -s -H "Accept: application/json" https://github.com/SeleniumHQ/selenium/releases/latest | jq -r ".tag_name" | cut -f 2 -d '-')
SELENIUM_URLPATH="$(echo ${SELENIUM_VERSION} | cut -f 1,2 -d '.')/selenium-server-standalone-${SELENIUM_VERSION}.jar"
mkdir -p /opt/selenium
wget --no-verbose -O /opt/selenium/selenium-server-standalone.jar "https://selenium-release.storage.googleapis.com/${SELENIUM_URLPATH}"
chmod a+r /opt/selenium/selenium-server-standalone.jar

echo "Selenium Bravo Servlet..."
BRAVOSERVLET_VERSION=$(curl -L -s -H "Accept: application/json" https://github.com/bravostudiodev/bravo-grid/releases/latest | jq -r ".tag_name")
mkdir -p /opt/selenium
wget --no-verbose -O /opt/selenium/selenium-bravo-servlet-${BRAVOSERVLET_VERSION}.jar \
 https://github.com/bravostudiodev/bravo-grid/releases/download/${BRAVOSERVLET_VERSION}/selenium-bravo-servlet-${BRAVOSERVLET_VERSION}-standalone.jar
ln -fs selenium-bravo-servlet-${BRAVOSERVLET_VERSION}.jar /opt/selenium/selenium-bravo-servlet.jar

echo -n "Cleanup..."
apt-get clean
rm -rf /var/lib/apt/lists/* /var/cache/apt/* || true
