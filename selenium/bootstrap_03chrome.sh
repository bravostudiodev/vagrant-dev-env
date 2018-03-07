#!/bin/sh

set -ex

# https://www.ubuntuupdates.org/pm/google-chrome-stable
# CHROME_VERSION="google-chrome-stable=61.0.3163.79-1"
# Google removes old versions from repositories, it is only possible to install stable beta or unstable versions
: ${CHROME_VERSION:="google-chrome-stable"}
: ${CHROME_DRIVER_VERSION:=$(curl -L -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE)}

apt-get update -qqy
# apt-cache show *google-chrome-stable*
rm -f /opt/google/chrome/google-chrome
apt-get install --reinstall -qqy --no-install-recommends ${CHROME_VERSION:-google-chrome-stable}
mv -f /opt/google/chrome/google-chrome /opt/google/chrome/google-chrome-original
cat > /usr/bin/google-chrome-no-sandbox << "EOF"
#!/usr/bin/env bash
echo $0 $@>>google-chrome-opt.log
exec -a "$0" "/opt/google/chrome/google-chrome-original" --no-sandbox "$@" 2>&1 | tee ~/google-chrome-no-sandbox-exec.log
EOF
chmod a+x /usr/bin/google-chrome-no-sandbox
ln -fs /usr/bin/google-chrome-no-sandbox /opt/google/chrome/google-chrome
update-alternatives --install /usr/bin/google-chrome google-chrome /usr/bin/google-chrome-no-sandbox 400

wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/${CHROME_DRIVER_VERSION}/chromedriver_linux64.zip
mkdir -p /usr/local/bin
unzip -o /tmp/chromedriver_linux64.zip -d /usr/local/bin
rm /tmp/chromedriver_linux64.zip
mv /usr/local/bin/chromedriver /usr/local/bin/chromedriver-${CHROME_DRIVER_VERSION}
chmod 755 /usr/local/bin/chromedriver-${CHROME_DRIVER_VERSION}
ln -fs /usr/local/bin/chromedriver-${CHROME_DRIVER_VERSION} /usr/local/bin/chromedriver

apt-get clean
rm -rf /var/lib/apt/lists/* /var/cache/apt/* || true
