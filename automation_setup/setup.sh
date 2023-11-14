#!/bin/bash

echo "APT install dependencies"
apt install -y wget git-all

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

