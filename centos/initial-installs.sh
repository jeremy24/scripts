#!/bin/bash

TMPDIR=/home/$USER/initial_install_tmp
BASIC_UTILS="fish vim nano ntp git wget"

EPEL_RPM_URL="dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm"
EPEL_RPM_DIR="epel-release-7-11.noarch.rpm"

 
GCC_7_URL="ftp://ftp.gnu.org/gnu/gcc/gcc-7.2.0/gcc-7.2.0.tar.gz"
GCC_7_TAR="gcc-7.2.0.tar.gz" 
GCC_7_DIR="gcc-7.2.0"
GCC_DEV_PKGS="libmpc-devel mpfr-devel gmp-devel"
GCC_CONF_OPTS="--with-system-zlib --disable-multilib --enable-languages=c,c++"


MPI_URL="https://www.open-mpi.org/software/ompi/v3.0/downloads/openmpi-3.0.0.tar.gz"
MPI_TAR="openmpi-3.0.0.tar.gz"
MPI_DIR="openmpi-3.0.0"
MPI_CONF_OPTS=" --prefix=/usr/local --enable-mpi-cxx --enable-oshmem --enable-cxx-exceptions"

UCX_URL="https://github.com/openucx/ucx/releases/download/v1.2.1/ucx-1.2.1.tar.gz"
UCX_TAR="ucx-1.2.1.tar.gz"
UCX_DIR="ucx-1.2.1"
UCX_CONF_OPTS="--disable-numa --with-mpi --with-sse42 --with-avx --prefix=/usr/local"

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
select yn in "Yes" "No"; do
	case $yn in 
		Yes) 	
			echo "Installing: " $BASIC_UTILS;
			pkginstall $BASIC_UTILS; 
			break;;
		No) 	break;;
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
			
			mkdir -p ucx;
			cd ucx;
			wget $UCX_URL;
			tar xvf $UCX_TAR;
			cd $UCX_DIR;
			./configure $UCX_CONF_OPTS;
			make -j $(nproc);
			make check;
			makeinstall;			
			
			
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










			

