#!/usr/bin/env bash
__DIR__="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 
__NAME__=$(basename $0)
echo -e "\e[1;97m" 1>&2
clear

if [ `whoami` != root ]; then
    echo -e "Please run this script using:  sudo $__NAME__ \e[0m"
    exit 1
fi

read -p "What is your non-root linux username : " USRNAME
read -p "If you want a location other than /home/$USRNAME/Rocketmap-Monocle, please supply the path here ( do not end with / ) : " INST_DIR


if [ -z $INST_DIR ] && [ -z $USRNAME ]; then error_exit "You really fucked up."; fi
if [ -z $INST_DIR ] && [ ! -z $USRNAME ]; then INST_DIR=/home/$USRNAME; fi
INST_DIR=$INST_DIR/Rocketmap-Monocle

VIRTUALENV=true
DATABASENAME=monocle

# GENERAL FUNCTIONS

trap clean_up SIGHUP SIGINT SIGTERM

function clean_up {
    echo "${__NAME__} : Cleaning up ..."
    rm -rf $INST_DIR;
    echo "${__NAME__} : Done.. bye!"
    echo -e "\e[0m"
	exit $1
}

function error_exit {
	echo "${__NAME__} : ${1:-"Unknown Error"}" 1>&2
	clean_up 1
}

function success_exit {
    echo "${__NAME__} : ${1:-"Completed"}" 1>&2
    
}

 
# CREATE INSTALLATION FOLDER AND SET PERMISSIONS
mkdir -p $INST_DIR
chown -R $USRNAME $INST_DIR
chmod -R 775 $INST_DIR

# DEPENDENCIES
if type -p python3.6
then
:
else
apt-get install -y make build-essential libssl-dev zlib1g-dev curl libwww-curl-perl   
apt-get install -y libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm 
apt-get install -y libncurses5-dev libncursesw5-dev xz-utils tk-dev libssl-dev
apt-get install -y libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev
apt-get install libgeos-dev


  if [ -d /usr/local ]
    then
    cd /usr/local 
  else
    mkdir -p /usr/local
    cd /usr/local 
  fi

wget https://www.python.org/ftp/python/3.6.2/Python-3.6.2.tgz
tar xvf Python-3.6.2.tgz
rm -f Python-3.6.2.tgz
cd Python-3.6.2
./configure --enable-optimizations
make -j8
make altinstall
fi

pip3.6 install --upgrade pip
pip3.6 install setuptools --upgrade

if node -v | grep -iE ".+8.+"
then
:
else
  if lsb_release -a | grep -iE "ubuntu"
    then
    # Using Ubuntu
    curl -sL https://deb.nodesource.com/setup_8.x | bash -
    apt-get install -y nodejs
  elif lsb_release -a | grep -iE "debian"
    then
    # Using Debian
    curl -sL https://deb.nodesource.com/setup_8.x | bash -
    apt-get install -y nodejs
  else
    echo "Cannot determine your linux version. please install Node(JS) 8 (documentation can be found online) and restart this script"
    exit 1
  fi
fi

apt-get install -y postgresql-client-9.4 postgresql-9.4-dbg postgresql-server-dev-9.4 git 

su -c "psql -d template1 -c \"CREATE USER monocle WITH PASSWORD 'monocle'\"" postgres
su -c "psql -c \"CREATE DATABASE monocle\"" postgres 
su -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE monocle TO monocle\"" postgres


cd ${INST_DIR} && { [[ $VIRTUALENV ]] && python3.6 -m venv . && . bin/activate ; } || { error_exit "Installation folder not found or error in Virtual Environment" ;}
cd Monocle
pip3.6 install --upgrade pip
pip3.6 install setuptools --upgrade
sed -i.bak '/mysqlclient/d' ./optional-requirements.txt 1>&2
pip3.6 install -r requirements.txt --upgrade -r optional-requirements.txt --upgrade


## CONFIG FILE NEEDS TO BE IN PLACE AT THIS POINT

if [ ! -f ${INST_DIR}/Monocle/monocle/config.py ]; then
error_exit "No Monocle config.py file present in ${INST_DIR}/Monocle/monocle/"
fi
## WIP ## 

python3.6 scripts/create_db.py
cd $__DIR__
deactivate

success_exit "Installation completed."

