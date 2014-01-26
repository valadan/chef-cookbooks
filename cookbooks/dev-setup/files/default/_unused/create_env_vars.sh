#!/bin/bash

#################################################################
# author:      Gary A. Stafford
# date:        2013-12-17
# source:      www.programmaticponderings.com
# description: complete code for install and config on Ubuntu
#              of jdk 1.7.0_45 in alteratives automatic mode
#################################################################

grep -q "JAVA_HOME" ${HOME}/.bashrc
if [ $? -ne 0 ]; then
	echo 'JAVA_HOME not found. Adding variables to ${HOME}/.bashrc'
	echo 'export JAVA_HOME=/usr/lib/jvm/jdk1.7.0_45' >> ${HOME}/.bashrc
	echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ${HOME}/.bashrc
	echo 'export CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/urandom' >> ${HOME}/.bashrc
	echo 'export ORACLE_HOME=$HOME/Oracle/products/Oracle_Home' >> ${HOME}/.bashrc
	echo 'export WL_HOME=$ORACLE_HOME/wlserver' >> ${HOME}/.bashrc
	echo 'export PATH=$WL_HOME/server/bin:$PATH' >> ${HOME}/.bashrc
	echo 'export WL_DOMAINS=/home/vagrant/Oracle/products/user_projects/domains' >> ${HOME}/.bashrc
	echo 'export CLASSPATH=$WL_HOME/server/lib/weblogic.jar:$CLASSPATH' >> ${HOME}/.bashrc
else
	echo 'JAVA_HOME found. No varibles added to ${HOME}/.bashrc'
fi

#bash --login
