#!/usr/bin/env bash

# locale-gen --purge en_US.UTF-8
# echo -e 'LANG="en_US.UTF-8"\nLANGUAGE="en_US:en"\n' > /etc/default/locale

sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

echo 'Updating and installing Ubuntu packages...'
add-apt-repository ppa:ubuntu-lxc/lxd-stable
apt-get update
apt-get install -y --no-install-recommends autoconf automake build-essential python-dev git golang openjdk-8-jdk-headless ant unzip libgconf2-4

echo 'Setting up correct env. variables'
echo "export GOPATH=~/gohome" >> ~/.bashrc
echo "export PATH=$PATH:~/gohome/bin:/usr/local/go/bin" >> ~/.bashrc

CHROME_DRIVER_VERSION=$(curl -s https://chromedriver.storage.googleapis.com/LATEST_RELEASE)
curl -s https://chromedriver.storage.googleapis.com/${CHROME_DRIVER_VERSION}/chromedriver_linux64.zip -O /tmp/chromedriver_linux64.zip
unzip /tmp/chromedriver_linux64.zip -d /usr/local/bin
rm /tmp/chromedriver_linux64.zip

git clone https://github.com/facebook/watchman.git
pushd watchman/
git checkout v4.7.0 && chmod +x ./autogen.sh
./autogen.sh && ./configure && make
make install && watchman --version
popd 
rm  -rf ./watchman
