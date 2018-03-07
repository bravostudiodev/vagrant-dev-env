#!/bin/sh

set -ex

cat > /etc/X11/fluxbox/fluxbox.menu-user << EOF
[begin] (fluxbox)
[exec] (Google Chrome) {/opt/google/chrome/google-chrome} </opt/google/chrome/product_logo_32.xpm>
[exec] (Firefox) {/usr/local/bin/firefox} </opt/firefox/browser/chrome/icons/default/default48.png>
[include] (/etc/X11/fluxbox/fluxbox-menu)
[end]
EOF

echo "Selenium..."
SELENIUM_VERSION=$(curl -L -s -H "Accept: application/json" https://github.com/SeleniumHQ/selenium/releases/latest | jq -r ".tag_name" | cut -f 2 -d '-')
SELENIUM_VERSION_BASE=$(echo ${SELENIUM_VERSION} | cut -f 1,2 -d '.')
SELENIUM_URLPATH=${SELENIUM_VERSION_BASE}/selenium-server-standalone-${SELENIUM_VERSION}.jar
mkdir -p /opt/selenium
wget --no-verbose -O /opt/selenium/selenium-server-standalone-${SELENIUM_VERSION}.jar "https://selenium-release.storage.googleapis.com/${SELENIUM_URLPATH}"
chmod a+r /opt/selenium/selenium-server-standalone-${SELENIUM_VERSION}.jar
ln -fs selenium-server-standalone-${SELENIUM_VERSION}.jar /opt/selenium/selenium-server-standalone.jar

echo "Selenium Bravo Servlet..."
BRAVOSERVLET_VERSION=$(curl -L -s -H "Accept: application/json" https://github.com/bravostudiodev/bravo-grid/releases/latest | jq -r ".tag_name")
mkdir -p /opt/selenium
wget --no-verbose -O /opt/selenium/selenium-bravo-servlet-${BRAVOSERVLET_VERSION}.jar \
 https://github.com/bravostudiodev/bravo-grid/releases/download/${BRAVOSERVLET_VERSION}/selenium-bravo-servlet-${BRAVOSERVLET_VERSION}-standalone.jar
ln -fs selenium-bravo-servlet-${BRAVOSERVLET_VERSION}.jar /opt/selenium/selenium-bravo-servlet.jar

# echo BRAVOEXT_PATH=LATEST> /opt/selenium/selenium_entry.cfg
echo BRAVOEXT_PATH=> /opt/selenium/selenium_entry.cfg
chmod a+rwx -R /opt/selenium
