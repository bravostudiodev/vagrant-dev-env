#!/bin/sh

set -ex

export APP_LANG="en_US.UTF-8"
export APP_LANGUAGE="en_US:en"
export APP_LC_ALL="en_US.UTF-8"

export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true
export TERM=linux

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
    build-essential \
    bzip2 \
    curl \
    ca-certificates \
    jq \
    libpython-dev \
    openjdk-8-jre-headless \
    procps \
    psmisc \
    python-pip \
    python-setuptools \
    rungetty \
    unzip \
    vim \
    wget

sed -e 's/securerandom\.source=file:\/dev\/random/securerandom\.source=file:\/dev\/urandom/' \
 -i /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/security/java.security

apt-get clean
rm -rf /var/lib/apt/lists/* /var/cache/apt/* || true
