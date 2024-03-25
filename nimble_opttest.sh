#!/bin/bash

export PATH="$HOME/miniconda3/bin:$PATH"

# Check if the number of arguments is correct
if [ "$#" -ne 1 ]; then
            echo "Usage: $0 <addr>"
                exit 1
fi

# Assign the argument to the 'addr' variable
addr=$1

# Install Go
curl https://dl.google.com/go/go1.22.1.linux-amd64.tar.gz | sudo tar -C /usr/local -zxvf -
cat <<'EOF' >> $HOME/.bashrc
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
source $HOME/.bashrc

# Install Miniconda
mkdir -p $HOME/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O $HOME/miniconda3/miniconda.sh
bash $HOME/miniconda3/miniconda.sh -b -u -p $HOME/miniconda3
rm -rf $HOME/miniconda3/miniconda.sh
eval "$(conda shell.bash hook)"
$HOME/miniconda3/bin/conda init bash
source $HOME/.bashrc

# Create and activate conda environment
conda create -n nimble python=3.11 -y
conda activate nimble

# Clone Nimble Miner repository
mkdir -p $HOME/nimble && cd $HOME/nimble
git clone https://github.com/silentnoname/nimble-miner-public.git
cd nimble-miner-public
git checkout test-optimize

# Install PM2

curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install pm2 -g


# Build and run Nimble Miner with the provided 'addr' argument
make install
source ./nimenv_localminers/bin/activate
pm2 start "make run addr=$addr" --name miner
pm2 logs 
