#!/bin/bash

YUM="/usr/bin/yum"
APT="/usr/bin/apt-get"

# What OS are we on???
if [ -e $APT ]; then
   if [ `grep Ubuntu /etc/issue|wc -l` -eq 1 ]; then
      OS="ubuntu"
   else
      OS="debian"
   fi
else
   if [ -e $YUM ]; then
      OS=`cat /etc/redhat-release | awk '{print tolower($1)}'`
      case "$OS" in
         fedora)
            VERSION=`cat /etc/redhat-release|awk '{print $4}'`
         ;;
         centos)
            VERSION=`head -1 /etc/redhat-release | sed -e 's/[^0-9.]*\([0-9.]*\).*/\1/g' | awk -F'.' '{print $1}'`
         ;;
      esac
   else
        OS="null"
        exit 1
   fi
fi

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

BLEU='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color



#case $OS in
#	centos)
#	;;
#	ubuntu|debian)
# 	;;
#esac


if [ $OS = 'centos' ]; then
	printf "${RED}#### START #### ${NC}"
	echo -e "\n##### package description (yum info $1) #####"
	repoquery -i $1 
	echo -e "\n##### package dependencies (repoquery -R $1) #####"
	repoquery -R  --alldeps $1 | head -5
	echo -e "\n##### what package(s) require mine (repoquery --whatrequires $1) #####"
	repoquery --whatrequires  --alldeps  $1 | head -5
	echo -e "\n##### files installed by the script (repoquery -l $1) #####"
	repoquery -l $1 | egrep -i  '(script|bin)' | grep -v .pm | head -50
	printf "${RED}#### STOP #### ${NC}\n"
else
        printf "${RED}#### START #### ${NC}"
        echo -e "\n##### package description (apt-cache show $1 ) #####"
        apt-cache show $1 |  grep -i -m 1 description 
        echo -e "\n##### package dependencies (apt-cache -i depends $1) #####"
        apt-cache -i depends $1 | head -5
        echo -e "\n##### what package(s) require mine (apt-cache -i rdepends $1) #####"
        apt-cache -i rdepends $1 | head -5
        echo -e "\n##### files installed by the script (dpkg-query -L  $1) #####"
        dpkg-query -L  $1 | egrep -i  '(script|bin)' | grep -v .pm | head -50
        printf "${RED}#### STOP #### ${NC}\n"
fi

#sudo apt-get install apt-file
#sudo apt-file update
#apt-file list <package_name>
