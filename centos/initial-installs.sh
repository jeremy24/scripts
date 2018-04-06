#!/bin/bash

## This is an initial installation script to add useful tools to a new CentOS installation.
## This will prompt the user about whether to install different things.

## sudo rights are NEEDED for this to work at all


TMPDIR=/home/$USER/initial_install_tmp
BASIC_UTILS="fish vim nano ntp git wget net-tools lsof"

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



DCKR_PKGS="yum-utils device-mapper-persistent-data lvm2"
DCKR_REPO="https://download.docker.com/linux/centos/docker-ce.repo"
DCKR_CE="docker-ce"

EPEL="epel-release"

mkdir -p $TMPDIR
cd $TMPDIR

shopt -s expand_aliases

alias pkgginstall="sudo yum groupinstall -y"
alias pkginstall="sudo yum install -y"
alias pkgupdate="sudo yum update -y"
alias makeinstall="sudo make install"
alias tail="whiptail --yesno"

END="20 60"

ask_user () {
    echo whiptail --yesno $1 20 60;
    if whiptail --yesno $1 20 60 ; then
        return 1;
    fi
    return 2;
}

# install EPEL repo
if tail "Do you want to add the epel-release repo?" ${END} ; then
    pkginstall ${EPEL};
fi


# update packages
if tail "Would you like to update system packages?" ${END}; then
    pkgupdate;
fi


# install utils
if tail "Would you like to install basic utilities?\nThey are: ${BASIC_UTILS}" ${END}; then
    pkginstall ${BASIC_UTILS};
fi


#install docker
if tail "Would you like to install docker?" ${END}; then
    pkginstall ${DCKR_PKGS};
    sudo yum-config-manager --add-repo ${DCKR_REPO};
    pkginstall ${DCKR_CE};
fi


# Install spack
if tail "Would you like to add spack?" ${END}; then
    cd ${TMPDIR};
    git clone https://github.com/spack/spack.git;
    . spack/share/spack/setup-env.sh;
fi


# Install dev tools
if tail "Would you like to add spack?" ${END}; then
    pkgginstall "Development tools";
    pkginstall valgrind;
fi


# Install dev tools
if tail "Would you like to enable a proxy for yum?" ${END}; then
    ENVFILE="/etc/environment";
    echo -n "Please enter the proxy ip/hostname:   ";
    read PROXYIP;
    echo -n "Please enter the proxy port:   ";
    read PROXYPORT;
    printf "http_proxy="${PROXYIP}":"${PROXYPORT}"\n">>${ENVFILE};
fi


# Install bind
if tail "Would you like to install bind?" ${END}; then
    pgkinstall bind bind-utils;
fi



# Install htop
if tail "Would you like to install htop?" ${END}; then
    pgkinstall ${EPEL};
    pkginstall htop;
fi




# Install gcc7
if tail "Would you like to install GCC7?" ${END}; then
    cd ${TMPDIR};
    mkdir -p gcc7;
    cd gcc7;
    curl ${GCC_7_URL} -O;
    tar xvf ${GCC_7_TAR};
    cd ${GCC_7_DIR};
    pkginstall ${GCC_DEV_PKGS};
    ./configure ${GCC_CONF_OPTS};
    make -j $(nproc);
    make check;
    makeinstall;
fi



#echo "Would you like to install OpenMPI?"
#select yn in "Yes" "No"; do
#	case $yn in
#		Yes)
#			echo "Installing OpenMPI";
#			echo "This may take awhile..";
#			cd $TMPDIR;
#
#			# build and install ucx portion
#			mkdir -p ucx;
#			cd ucx;
#			wget $UCX_URL;
#			tar xvf $UCX_TAR;
#			cd $UCX_DIR;
#			./configure $UCX_CONF_OPTS;
#			make -j $(nproc);
#			make check;
#			makeinstall;
#
#			# build and install open mpi
#			cd $TMPDIR;
#			mkdir -p mpi;
#			cd mpi;
#			wget $MPI_URL;
#			tar xvf $MPI_TAR;
#			cd $MPI_DIR;
#			echo $(ls);
#			./configure $MPI_CONF_OPTS;
#			make -j $(nproc);
#			make check;
#			makeinstall;
#			break;;
#		No) break;;
#	esac
#done










			

