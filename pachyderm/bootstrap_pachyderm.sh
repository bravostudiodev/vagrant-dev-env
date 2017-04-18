#!/usr/bin/env bash

cp /shared/check_ready.sh ./
chmod +x ./check_ready.sh

#add allow-privileged flags to kubelete
sudo sed -i 's/kubelet \\/kubelet \\\n--allow-privileged=true \\/' /etc/systemd/system/kubelet.service
sudo sed -i 's/hyperkube apiserver \\/hyperkube apiserver \\\n--allow-privileged=true \\/' /etc/systemd/system/kube-apiserver.service
sudo systemctl daemon-reload
sudo systemctl restart kubelet
sudo systemctl restart kube-apiserver.service

#install socat (neede for port forwarding)
echo "Installing socat utility ..."
wget -q http://www.dest-unreach.org/socat/download/socat-1.7.3.2.tar.gz
tar -xzvf ./socat-1.7.3.2.tar.gz 1> /dev/null
pushd ./socat-1.7.3.2
./configure 1> /dev/null
make 1> /dev/null
sudo make install 1> /dev/null
popd
rm -rf ./socat-1.7.3.2
rm  ./socat-1.7.3.2.tar.gz

#install pachctl
echo "Downloading and installing pachctl ..."
PACHCTL_VERSION=$(curl -s https://github.com/pachyderm/pachyderm/releases/latest | sed -n 's/.*tag\/v\([0-9.]*\).*/\1/p')
curl -Lso pachctl.tar.gz https://github.com/pachyderm/pachyderm/releases/download/v${PACHCTL_VERSION}/pachctl_${PACHCTL_VERSION}_linux_amd64.tar.gz
sudo tar -C /usr/bin -xzvf pachctl.tar.gz --wildcards */pachctl --strip 1
rm pachctl.tar.gz

#deploy pachd on kubernetes
echo "Deploying pachyderm ..."
pachctl undeploy
pachctl deploy local
echo "Waiting pachyderm to become ready ..."
until timeout 1s ./check_ready.sh app=pachd; do sleep 1; done
echo "Pachyderm deployed and ready"

rm ./check_ready.sh

echo "Pulling docker image pachyderm/pachyderm_jupyter (size about 1 GB)..."
docker pull pachyderm/pachyderm_jupyter
