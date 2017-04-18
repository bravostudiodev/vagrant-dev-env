#!/usr/bin/env bash

#install kubectl
KUBECTL_VERSION=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl
chmod +x kubectl
mkdir -p ~/bin/
mv kubectl ~/bin/
echo "source <(kubectl completion bash)" >> ~/.bashrc
source <(kubectl completion bash)

#install pachctl
echo "Downloading and installing pachctl ..."
PACHCTL_VERSION=$(curl -s https://github.com/pachyderm/pachyderm/releases/latest | sed -n 's/.*tag\/v\([0-9.]*\).*/\1/p')
curl -Lso pachctl.tar.gz https://github.com/pachyderm/pachyderm/releases/download/v${PACHCTL_VERSION}/pachctl_${PACHCTL_VERSION}_linux_amd64.tar.gz
mkdir -p ~/bin/
tar -C ~/bin -xzvf pachctl.tar.gz --wildcards */pachctl --strip 1
rm pachctl.tar.gz

#add route
sudo ip route add 10.0.0.0/24 via 10.10.0.2

#configure kubectl
kubectl config set-cluster kubetest-server --server=http://10.10.0.2:8080
kubectl config set-context kubetest-context --cluster=kubetest-server 
kubectl config use-context kubetest-context
kubectl config view

#display cluster info
kubectl cluster-info
# Kubernetes master is running at http://10.10.0.2:8080
# dashboard is running at http://10.10.0.2:8080/api/v1/proxy/namespaces/kube-system/services/dashboard
# KubeDNS is running at http://10.10.0.2:8080/api/v1/proxy/namespaces/kube-system/services/kube-dns
