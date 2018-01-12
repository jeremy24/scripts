#!/bin/bash



echo "This script will set up a jupyter server will SSL support."
echo "You MUST have sudo rights to run this script."
echo

echo -n "Please enter the IP address to host on:  "
read IP

echo -n "Please enter the port to host on:  "
read PORT

CONDAURL='https://repo.continuum.io/archive/Anaconda3-5.0.1-Linux-x86_64.sh'
CONDASCRIPT='Anaconda3-5.0.1-Linux-x86_64.sh'
CONDADIR=$HOME'/anaconda3/bin' 

RPMURL='https://centos7.iuscommunity.org/ius-release.rpm'
PACKAGES='python36u bzip2'


shopt -s expand_aliases

alias pkginstall="sudo yum install -y "
alias pkgupdate="sudo yum upgrade -y"
alias dolink="sudo link"
alias jupn="jupyter notebook"

echo "We will first install prereq packages."
echo

## update first
pkgupdate

# then install
pkginstall $RPMURL
pkginstall $PACKAGES

echo "Since the python3 exe name is annoying, we now create a link to it named python3"
echo 

dolink "/bin/python3.6"  "/bin/python3"

echo "We will now setup Anaconda"
echo

read -e -p "Enter the Anaconda install dir:  " -i $HOME"/libs" INSDIR

mkdir -p $INSDIR
cd $INSDIR

#wget $CONDAURL
chmod +x $CONDASCRIPT
#./$CONDASCRIPT

echo 
echo "We accuse that the conda binaries are in "$CONDADIR" if not, this will not work."
echo

PATH=$CONDADIR:$PATH

jupn --generate-config
cd $HOME'/.jupyter/'

CONFIG=$HOME'/.jupyter/jupyter_notebook_config.py'
CONFIGBACKUP=$HOME'/.jupyter/backup.config'
KEY=$HOME'/.jupyter/jupyter.key'
PEM=$HOME'/.jupyter/jupyter.pem'

mv $CONFIG $CONFIGBACKUP

echo
echo "Enter your jupyter password:"
jupn password
SSLOPTS='-x509 -nodes -days 3000 -newkey rsa:2048 -keyout '$KEY' -out '$PEM
openssl req $SSLOPTS

# first will overwite the file contents
printf 'c.NotebookApp.certfile = "'$PEM'"\n'    > $CONFIG
printf 'c.NotebookApp.keyfile  = "'$KEY'"\n'    >> $CONFIG
printf 'c.NotebookApp.ip = "'$IP'"\n'           >> $CONFIG
printf 'c.NotebookApp.password = "PASSWORD"\n'  >> $CONFIG
printf 'c.NotebookApp.open_browser = "False"'   >> $CONFIG
printf 'c.NotebookApp.port = "'$PORT'"'         >> $CONFIG

sudo firewall-cmd --zone=public --add-port=$PORT/tmp

echo 
echo "Please copy your hashed password from the JSON file in "$HOME"/.jupyter into the .py config file located in the same directory."
echo










