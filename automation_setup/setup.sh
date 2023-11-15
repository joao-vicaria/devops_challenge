#!/bin/bash

echo "APT install dependencies"
sudo apt install -y wget git-all

echo "Install jq"
brew install jq

echo "Install Miniconda"
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -rf ~/miniconda3/miniconda.sh
~/miniconda3/bin/conda init bash
~/miniconda3/bin/conda init zsh

echo "Clone nameko repo"
cd ~/
git clone https://gitlab.com/devprodexp/nameko-devexp.git

echo "Create and Set conda environment"
cd ~/nameko-devexp
~/miniconda3/bin/conda env create -f environment_dev.yml
source ~/miniconda3/etc/profile.d/conda.sh
conda activate nameko-devex

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
cd ~/nameko-devexp
sed '9 s/^# //' manifest.yml
sed '10 s/^# //' manifest.yml
sed '11 s/^# //' manifest.yml
sed '12 s/^# //' manifest.yml
epinio push -n namekoapp manifest.yml