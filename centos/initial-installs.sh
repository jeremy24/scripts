#!/bin/bash

## This is an initial installation script to add useful tools to a new CentOS installation.
## This will prompt the user about whether to install different things.

## sudo rights are NEEDED for this to work at all


TMPDIR=/home/$USER/initial_install_tmp
BASIC_UTILS="fish vim nano ntp git wget"

EPEL_RPM_URL="dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm"
EPEL_RPM_DIR="epel-release-7-11.noarch.rpm"

 
GCC_7_URL="ftp://ftp.gnu.org/gnu/gcc/gcc-7.2.0/gcc-7.2.0.tar.gz"
GCC_7_TAR="gcc-7.2.0.tar.gz" 
GCC_7_DIR="gcc-7.2.0"
GCC_DEV_PKGS="libmpc-devel mpfr-devel gmp-devel"
GCC_CONF_OPTS="--with-system-zlib --disable-multilib --enable-languages=c,c++"

# Values used by the MPI portion
MPI_URL="https://www.open-mpi.org/software/ompi/v3.0/downloads/openmpi-3.0.0.tar.gz"
MPI_TAR="openmpi-3.0.0.tar.gz"
MPI_DIR="openmpi-3.0.0"
MPI_CONF_OPTS=" --prefix=/usr/local/mpi --enable-oshmem --with-ucx=/usr/local/ucx"

# Used by the ucx portion
UCX_URL="https://github.com/openucx/ucx/releases/download/v1.2.1/ucx-1.2.1.tar.gz"
UCX_INTIALL_PATH="/usr/local/ucx"
UCX_TAR="ucx-1.2.1.tar.gz"
UCX_DIR="ucx-1.2.1"
UCX_CONF_OPTS="--disable-numa --with-mpi --with-sse42 --prefix=/usr/local/ucx"

mkdir -p $TMPDIR
cd $TMPDIR

shopt -s expand_aliases

alias pkgginstall="sudo yum groupinstall -y"
alias pkginstall="sudo yum install -y"
alias pkgupdate="sudo yum update -y"
alias makeinstall="sudo make install"


echo "Would you like to update packages?"
select yn in "Yes" "No"; do
	case $yn in 
		Yes) 
			echo  "sudo yum update -y";
			pkgupdate;
			break;;
		No) 	break;;
	esac
done

echo "Would you like to install basic utilities?"
echo "They are: "$BASIC_UTILS
select yn in "Yes" "No"; do
	case $yn in 
		Yes) 	
			echo "Installing: " $BASIC_UTILS;
			pkginstall $BASIC_UTILS; 
			break;;
		No) 	break;;
	esac
done


echo "Would you like to add spack?"
select yn in "Yes" "No"; do
	case $yn in 
		Yes)
			cd $TMP_DIR;
			git clone https://github.com/spack/spack.git;
			. spack/share/spack/setup-env.sh;
			break;;
		No) break;;
	esac
done

echo "Would you like to install dev tools?"
select yn in "Yes" "No"; do
	case $yn in 
		Yes)	
			echo "Installing Development tools group";
			pkgginstall "Development tools";
			pkginstall valgrind;
			break;;
		No)	break;;
	esac
done

echo "Would you like to enable a proxy for yum?"
select yn in "Yes" "no"; do
	case $yn in 
		Yes) 
			ENVFILE="/etc/environment";
			echo -n "Please enter the proxy ip/hostname:   ";
                        read PROXYIP;
			echo -n "Please enter the proxy port:   ";
			read PROXYPORT;	
			printf "http_proxy="$PROXYIP":"$PROXYPORT"\n">>$ENVFILE; 			
			break;;
		No)	break;;
	esac
done


echo "Would you like to install bind?"
select yn in "Yes" "No"; do
	case $yn in
		Yes) 
			pgkinstall bind bind-utils;
			break;;
		No)	break;;
	esac
done


echo "Would you like to install htop?"
select yn in "Yes" "No"; do
	case $yn in 
		Yes) 
			wget $EPEL_RPM_URL;
			sudo rpm -ihv $EPEL_RPM_DIR;
			pkginstall htop;
			break;;
		No) break;;
	esac
done



echo "Would you like to install git and configure it?"
select yn in "Yes" "No"; do
	case $yn in
		Yes)
			pkginstall git;
			echo -n "Please enter you git username:  ";
			read gituser;
			echo -n "Please enter your git email:  ";
			read gitemail;
			git config --global user.name $gituser;
			git config --global user.email $gitemail;
			git config --global credential.helper store;
			git config --global credential.helper 'cache --timeout 3600';
			echo "Your git password will be cached for 3600 seconds.";
			break;;
		No)
			break;;
	esac
done
	
echo "Would you like to install gcc 7?"
select yn in "Yes" "No"; do
	case $yn in 
		Yes) 
			echo "Installing gcc 7, this may take awhile";
			echo "Downloading file";
			cd $TMP_DIR;
			mkdir -p gcc7;
			cd gcc7;
			curl $GCC_7_URL -O;
			echo "Unpacking";
			tar xvf $GCC_7_TAR;
			cd $GCC_7_DIR;
			echo "Building";
			pkginstall $GCC_DEV_PKGS;
			./configure $GCC_CONF_OPTS;
			make -j $nproc;
			make check;
			makeinstall;
			break;;
		No) break;;
	esac
done
			
			
echo "Would you like to install OpenMPI?"
select yn in "Yes" "No"; do
	case $yn in 
		Yes)
			echo "Installing OpenMPI";
			echo "This may take awhile..";
			cd $TMPDIR;
			
			# build and install ucx portion
			mkdir -p ucx;
			cd ucx;
			wget $UCX_URL;
			tar xvf $UCX_TAR;
			cd $UCX_DIR;
			./configure $UCX_CONF_OPTS;
			make -j $(nproc);
			make check;
			makeinstall;		
	
			# build and install open mpi			
			cd $TMPDIR;
			mkdir -p mpi;
			cd mpi;
			wget $MPI_URL;
			tar xvf $MPI_TAR;
			cd $MPI_DIR;
			echo $(ls);
			./configure $MPI_CONF_OPTS;
			make -j $(nproc);
			make check;
			makeinstall;
			break;;
		No) break;;
	esac
done			










			

