#!/bin/bash

echo "APT install dependencies"
sudo apt install -y wget git-all
sudo export PATH=$PATH:/home/linuxbrew/.linuxbrew/bin

echo "Install Kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

echo "Install Helm"
wget https://get.helm.sh/helm-v3.13.2-linux-amd64.tar.gz
tar -zxvf ./helm*
sudo mv linux-amd64/helm /usr/local/bin/helm

echo "Install docker"
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "Install jq"
brew install jq

#echo "Install Miniconda"
#mkdir -p ~/miniconda3
#wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
#bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
#rm -rf ~/miniconda3/miniconda.sh
#~/miniconda3/bin/conda init bash
#~/miniconda3/bin/conda init zsh

echo "Clone nameko repo"
cd ~/
git clone https://gitlab.com/devprodexp/nameko-devexp.git

echo "Create and Set conda environment"
cd ~/nameko-devexp
#~/miniconda3/bin/conda env create -f environment_dev.yml
#source ~/miniconda3/etc/profile.d/conda.sh
#conda activate nameko-devex

echo "K3D Install"
sudo wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
sudo k3d cluster create epinio
sudo kubectl cluster-info

echo "Cert-Manager Install"
sudo helm repo add jetstack https://charts.jetstack.io
sudo helm repo update
sudo helm upgrade --install cert-manager jetstack/cert-manager --namespace cert-manager  --set installCRDs=true --set extraArgs={--enable-certificate-owner-ref=true} --create-namespace

echo "Epinio Install"
sudo helm repo add epinio https://epinio.github.io/helm-charts
sudo helm repo update
INTERNAL_IP=`sudo kubectl get nodes -o wide|grep -e k3d-epinio-server-0|awk '{ print $6 }'`
sudo helm upgrade --install epinio epinio/epinio --namespace epinio --create-namespace --set global.domain=$INTERNAL_IP.sslip.io
brew install epinio

echo "Push nameko-sample to Epinio"
epinio login -u admin -p password https://epinio.$INTERNAL_IP.sslip.io
sudo helm repo add bitnami https://charts.bitnami.com/bitnami
sudo helm repo update
sudo helm install rabbitmq oci://registry-1.docker.io/bitnamicharts/rabbitmq -n workspace
sudo helm install redis oci://registry-1.docker.io/bitnamicharts/redis -n workspace
sudo helm install postgresql oci://registry-1.docker.io/bitnamicharts/postgresql --set auth.postgresPassword=postgres --set auth.database=orders -n workspace


epinio push -n namekoapp epinio-manifest.yml