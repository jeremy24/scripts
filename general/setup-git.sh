#/bin/bash



shopt -s expand_aliases

alias pgkinstall="sudo yum install -y"


echo "Setting up git..."

# install git
pkginstall git


echo "Would you like to save your git credentials on this machine?"
select yn in "Yes" "No"; do
	case $yn in
		Yes)
			git config credential.helper store;
			git config --global credential.helper 'cache --timeout 3600';
			break;;
		No)	break;;
	esac
done


