#!/usr/bin/env bash

echo 'Updating and installing Ubuntu packages...'
add-apt-repository ppa:ubuntu-lxc/lxd-stable
apt-get update
apt-get install -y --force-yes git
apt-get install -y --force-yes golang

echo 'Setting up correct env. variables'
echo "export GOPATH=/home/vagrant/gohome" >> /home/vagrant/.bashrc
echo "export PATH=$PATH:/home/vagrant/gohome/bin:/usr/local/go/bin" >> /home/vagrant/.bashrc
