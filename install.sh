#!/bin/bash 
# 
#  
clear 
echo "What's your node? 
1. Master 
2. Node" 
read -p '[1/2]: ' reply 
if [ "$reply" == 1 ] || [ "$reply" == 2 ];then 
        clear 
else 
        echo 'Error!Just 1 or 2' 
	exit 
fi 

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo 
sudo yum install -y docker-ce-20.10.5 docker-ce-cli-20.10.5 containerd.io-20.10.5 
sudo systemctl enable docker.socket --now

echo '[kubernetes]  
name=Kubernetes  
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64  
enabled=1  
gpgcheck=1  
repo_gpgcheck=1  
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg' > ~/kubernetes.repo

sudo chown root. ~/kubernetes.repo 
sudo mv ~/kubernetes.repo /etc/yum.repos.d/kubernetes.repo 
sudo yum install -y kubelet kubeadm kubectl 
sudo systemctl enable kubelet && sudo systemctl start kubelet 
sudo sed -i 's/#net\/ipv4\/ip_forward=1/net\/ipv4\/ip_forward=1/'g /etc/ufw/sysctl.conf 
sudo systemctl disable ufw && sudo systemctl stop ufw 

echo 'net.bridge.bridge-nf-call-ip6tables = 1  
net.bridge.bridge-nf-call-iptables = 1' > ~/k8s.conf

sudo chown root. ~/k8s.conf 
sudo mv ~/k8s.conf /etc/sysctl.d/k8s.conf 
sudo sysctl --system 

sudo setenforce 0 
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/'g /etc/selinux/config 

sudo sed -i '/swap/d' /etc/fstab  
sudo swapoff -a 

clear 
# Master 
if [ "$reply" == 1 ];then 
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 
mkdir -p $HOME/.kube  
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config  
sudo chown $(id -u):$(id -g) $HOME/.kube/config  
export KUBECONFIG=/etc/kubernetes/admin.conf 
sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml 
echo && echo "You need join node." 
elif [ "$reply" == 2 ];then 
echo "You need Join" 
fi
