#!/bin/bash

shopt -s expand_aliases
DIR=/opt/headphones

# make sure git is installed
sudo apt-get install git-core -y

# make sure python is installed
sudo apt-get install python -y

echo "Setting up in "$DIR

# clone the repo
cd /opt . 
sudo git clone https://github.com/rembo10/headphones.git

# enter the repo
cd /opt/headphones

# setup to run as daemon
sudo touch /etc/default/headphones

# make new user
sudo adduser --system --no-create-home headphones
sudo chown headphones:nogroup -R $DIR

sudo chmod +x $DIR/init-scripts/init.ubuntu
sudo ln -s $DIR/init-scripts/init.ubuntu /etc/init.d/headphones
sudo update-rc.d headphones defaults
sudo update-rc.d headphones enable

printf '[General]\nhttp_host=0.0.0.0\nhttp_port=8080' > /opt/headphones/config.ini


sudo service headphones start
sudo service headphones status

echo "Change necessary options in /etc/headphones/default as needed"
echo "To access remotely, change /opt/headphones/config.ini to listen to the proper interface"
