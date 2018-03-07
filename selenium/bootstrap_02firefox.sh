#!/bin/sh

set -ex

: ${FIREFOX_VERSION:=58.0.2}
: ${GECKODRIVER_VERSION:=$(curl -L -s -H "Accept: application/json" https://github.com/mozilla/geckodriver/releases/latest | jq -r ".tag_name")}

apt-get update -qqy
apt-get install --reinstall -qqy --no-install-recommends firefox
wget --no-verbose -O /tmp/firefox.tar.bz2 https://download-installer.cdn.mozilla.net/pub/firefox/releases/${FIREFOX_VERSION}/linux-x86_64/en-US/firefox-${FIREFOX_VERSION}.tar.bz2
apt-get -y purge firefox
rm -rf /opt/firefox
tar -C /opt -xjf /tmp/firefox.tar.bz2
rm /tmp/firefox.tar.bz2
ln -fs /opt/firefox/firefox /usr/local/bin/firefox-${FIREFOX_VERSION}
ln -fs /usr/local/bin/firefox-${FIREFOX_VERSION} /usr/local/bin/firefox
update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/local/bin/firefox 40

wget --no-verbose -O /tmp/geckodriver.tar.gz https://github.com/mozilla/geckodriver/releases/download/${GECKODRIVER_VERSION}/geckodriver-${GECKODRIVER_VERSION}-linux64.tar.gz
mkdir -p /usr/local/bin
tar -C /usr/local/bin -zxf /tmp/geckodriver.tar.gz
rm /tmp/geckodriver.tar.gz
mv /usr/local/bin/geckodriver /usr/local/bin/geckodriver-${GECKODRIVER_VERSION}
chmod 755 /usr/local/bin/geckodriver-${GECKODRIVER_VERSION}
ln -fs geckodriver-${GECKODRIVER_VERSION} /usr/local/bin/geckodriver

apt-get clean
rm -rf /var/lib/apt/lists/* /var/cache/apt/* || true
