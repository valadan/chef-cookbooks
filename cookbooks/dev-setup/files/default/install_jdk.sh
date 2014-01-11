#!/bin/bash

#################################################################
# author:      Gary A. Stafford
# date:	       2013-12-17
# source:      www.programmaticponderings.com
# description: complete code for install and config on Ubuntu
#              of jdk 1.7.0_45 in alteratives automatic mode
#################################################################

########## variables start ########## 

# Vagrant VM User - not best solution.
# Need to research better solution!
vm_user=vagrant

# priority value
priority=20000

# path to binaries directory
binaries=/usr/bin

# path to libraries directory
libraries=/usr/lib

# path to new java version
javapath=$libraries/jvm/jdk1.7.0_45

# path to downloaded java version
java_download=/home/$vm_user/jdk-7u45-linux-x64.tar.gz

########## variables end ########## 

cd $libraries
[ -d jvm ] || sudo mkdir jvm
cd /home/$vm_user/

# change permissions on jvm subdirectory
sudo chmod +x $libraries/jvm/

# extract new version of java from the downloaded tarball
if [ -f $java_download ]; then
	sudo tar -zxf $java_download -C $libraries/jvm
else
	echo "Cannot locate Java download. Check 'java_download' variable."
	echo 'Exiting script.'
	exit 1
fi

# install and config java web start (java)
sudo update-alternatives --install $binaries/java java \
	$javapath/jre/bin/java $priority
sudo update-alternatives --auto java

# install and config java web start (javaws)
sudo update-alternatives --install $binaries/javaws javaws \
	$javapath/jre/bin/javaws $priority
sudo update-alternatives --auto javaws

# install and config java compiler (javac)
sudo update-alternatives --install $binaries/javac javac \
	$javapath/bin/javac $priority
sudo update-alternatives --auto javac

# install and config java archive tool (jar)
sudo update-alternatives --install $binaries/jar jar \
	$javapath/bin/jar $priority
sudo update-alternatives --auto jar

# jar signing and verification tool (jarsigner)
sudo update-alternatives --install $binaries/jarsigner jarsigner \
	$javapath/bin/jarsigner $priority
sudo update-alternatives --auto jarsigner

# install and config java tool for generating api documentation in html  (javadoc)
sudo update-alternatives --install $binaries/javadoc javadoc \
	$javapath/bin/javadoc $priority
sudo update-alternatives --auto javadoc

# install and config java disassembler (javap)
sudo update-alternatives --install $binaries/javap javap \
	$javapath/bin/javap $priority
sudo update-alternatives --auto javap

# install and config file that creates c header files and c stub (javah)
sudo update-alternatives --install $binaries/javah javah \
	$javapath/bin/javah $priority
sudo update-alternatives --auto javah

# jexec utility executes command inside the jail (jexec)
sudo update-alternatives --install $binaries/jexec jexec \
	$javapath/lib/jexec $priority
sudo update-alternatives --auto jexec

# install and config file to run applets without a web browser (appletviewer)
sudo update-alternatives --install $binaries/appletviewer appletviewer \
	$javapath/bin/appletviewer $priority
sudo update-alternatives --auto appletviewer

# install and config java plugin for linux (mozilla-javaplugin.so)
if [ -f '$libraries/mozilla/plugins/libjavaplugin.so mozilla-javaplugin.so' ]; then
	sudo update-alternatives --install \
		$libraries/mozilla/plugins/libjavaplugin.so mozilla-javaplugin.so \
		$javapath/jre/lib/amd64/libnpjp2.so $priority
	sudo update-alternatives --auto mozilla-javaplugin.so
else
	echo 'Mozilla Firefox not found. Java Plugin for Linux will not be installed.'
fi

echo
echo '*** Java update script completed successfully ***'
echo

# confirm alternative for java-related executables
update-alternatives --get-selections | \
  grep -e java -e jar -e jexec -e appletviewer -e mozilla-javaplugin.so
