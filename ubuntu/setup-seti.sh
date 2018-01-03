#!/bin/bash


URL="http://setiathome.berkeley.edu/" 

if [ $1 ]; then
	sudo apt install boinc-client -y ;
	boinccmd --project_attach $URL $1
	echo "Boinc installed and attached, please ensure it is now running"
else
	echo 'Please provide a SETI@home account token as the first argument'
fi



