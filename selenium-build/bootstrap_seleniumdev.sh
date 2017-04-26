#!/usr/bin/env bash

echo 'Updating and installing Ubuntu packages...'
add-apt-repository ppa:ubuntu-lxc/lxd-stable
apt-get update
apt-get install -y --no-install-recommends git golang openjdk-8-jdk-headless ant

echo 'Setting up correct env. variables'
echo "export GOPATH=~/gohome" >> ~/.bashrc
echo "export PATH=$PATH:~/gohome/bin:/usr/local/go/bin" >> ~/.bashrc
