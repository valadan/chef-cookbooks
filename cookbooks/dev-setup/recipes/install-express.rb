#
# Cookbook Name:: dev-setup
# Recipe:: install-express
#
# Copyright 2013, Gary A. Stafford
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# referece links:
# http://docs.oracle.com/cd/E17781_01/install.112/e18802/toc.htm#BABCEAHD
# http://docs.oracle.com/cd/E17781_01/install.112/e18802/toc.htm

# apt update/upgrade
bash "apt-update" do
  code "sudo apt-get update -y && sudo apt-get upgrade -y"
  action :run
end

# install required packages
%w{unixodbc unzip alien libaio1}.each do |pkg|
  package pkg do
    action :upgrade
  end
end

# make swapfile
bash "make-swap" do
  code <<-EOH
    dd if=/dev/zero of=/home/swapfile bs=1024 count=1048576
    mkswap /home/swapfile
    swapon /home/swapfile
    swapon -a
    echo '/home/swapfile swap swap defaults 0 0' >> /etc/fstab
    swapon -s
  EOH
end

# config chkconfig
bash "config-chkconfig" do
  code <<-EOH
    cat > /sbin/chkconfig <<-EOF
#!/bin/bash
# Oracle 11gR2 XE installer chkconfig hack for Ubuntu
file=/etc/init.d/oracle-xe
if [[ ! `tail -n1 $file | grep INIT` ]]; then
echo >> $file
echo '### BEGIN INIT INFO' >> $file
echo '# Provides: OracleXE' >> $file
echo '# Required-Start: $remote_fs $syslog' >> $file
echo '# Required-Stop: $remote_fs $syslog' >> $file
echo '# Default-Start: 2 3 4 5' >> $file
echo '# Default-Stop: 0 1 6' >> $file
echo '# Short-Description: Oracle 11g Express Edition' >> $file
echo '### END INIT INFO' >> $file
fi
update-rc.d oracle-xe defaults 80 01
    EOF
    sudo chmod 755 /sbin/chkconfig
  EOH
  action :run
  not_if { ::File.exists?("/sbin/chkconfig") }
end

# create kernel parameters
bash "create-kernel-params" do
code <<-EOH
    echo "### Oracle 11g Kernel Parameters ####
fs.suid_dumpable = 1
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmall = 2097152
kernel.shmmax = 536870912
kernel.shmmni = 4096

### semaphores: semmsl, semmns, semopm, semmni ####
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default=4194304
net.core.rmem_max=4194304
net.core.wmem_default=262144
net.core.wmem_max=1048586" > /etc/sysctl.d/60-oracle.conf
  EOH
  action :run
  not_if { ::File.exists?("/etc/sysctl.d/60-oracle.conf") }
end

# misc commands
bash "misc-commands" do
  code <<-EOH
    sudo ln -s /usr/bin/awk /bin/awk
    sudo mkdir /var/lock/subsys
    touch /var/lock/subsys/listener
  EOH
  action :run
  not_if { ::File.exists?("/var/lock/subsys") }
end

# copy zipped Oracle Database XE package to tmp directory
remote_file "copy-express-to-cache" do 
  path "#{Chef::Config[:file_cache_path]}/#{node['dev']['express_package']}.zip"
  source "file:///#{node['dev']['global_sync_folder']}/#{node['dev']['express_package']}.zip"
  checksum node['dev']['wls_pkg_checksum']
  mode 0755
  not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/#{node['dev']['express_package']}.zip") }
end

# unzip Oracle Database XE package
bash "unzip-express" do
  cwd Chef::Config[:file_cache_path]
  code "unzip -o #{node['dev']['express_package']}.zip; rm #{node['dev']['express_package']}.zip"
  action :run
  not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/Disk1/#{node['dev']['express_package']}") }
end

# covert to .deb with alien for Ubuntu
bash "convert-rpm" do
  cwd "#{Chef::Config[:file_cache_path]}/Disk1"
  code "alien --to-deb --scripts #{node['dev']['express_package']}; rm #{node['dev']['express_package']}"
  creates node['dev']['express_package_deb']
  action :run
  not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/Disk1/#{node['dev']['express_package_deb']}") }
end

# create response file dynamically
bash "create-response-file" do
  cwd "#{Chef::Config[:file_cache_path]}/Disk1/response"
  code <<-EOH
    echo "ORACLE_LISTENER_PORT=#{node['dev']['express_listen_port']}
ORACLE_HTTP_PORT=#{node['dev']['express_http_port']}
ORACLE_PASSWORD=#{node['dev']['express_password']}
ORACLE_CONFIRM_PASSWORD=#{node['dev']['express_password']}
ORACLE_DBENABLE=y" > #{node['dev']['express_response_file']}
  EOH
  action :run
end

# second attempt to fix memory error
# http://meandmyubuntulinux.blogspot.com/2012/06/trouble-shooting-oracle-11g.html
bash "shared-memory" do
  code <<-EOH
  rm /dev/shm 2>/dev/null
  mkdir /dev/shm 2>/dev/null
  mount -t tmpfs shmfs -o size=2048m /dev/shm
  cat > /etc/rc2.d/S01shm_load <<-EOF
#!/bin/sh
case "$1" in
start) mkdir /var/lock/subsys 2>/dev/null
  touch /var/lock/subsys/listener
  rm /dev/shm 2>/dev/null
  mkdir /dev/shm 2>/dev/null
  mount -t tmpfs shmfs -o size=2048m /dev/shm ;;
*) echo error
   exit 1 ;;
esac
  EOF
  chmod 755 /etc/rc2.d/S01shm_load 
  EOH
end

# environment variables are set properly each time you log in or open a new shell
bash "bash-login" do
code <<-EOH
  echo "
. /u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export ORACLE_SID=XE
export NLS_LANG=`$ORACLE_HOME/bin/nls_lang.sh`
export ORACLE_BASE=/u01/app/oracle
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export PATH=$ORACLE_HOME/bin:$PATH"
  >> #{node['dev']['global_user_home']}/.bashrc
  EOH
  user node['dev']['global_user']
  group node['dev']['global_group']
  action :run
end

# install Oracle Database XE
bash "install-express" do
  cwd "#{Chef::Config[:file_cache_path]}/Disk1"
  code <<-EOH
    sudo dpkg --install #{node['dev']['express_package_deb']} \
    > /tmp/XEsilentinstall.log
  EOH
  action :run
  not_if { ::File.exists?("/etc/init.d/oracle-xe") }
end

# configure Oracle Database XE
bash "configure-express" do
    code <<-EOH
      /etc/init.d/oracle-xe configure \
      responseFile=#{Chef::Config[:file_cache_path]}/Disk1/response/#{node['dev']['express_response_file']} \
      >> /tmp/XEsilentinstall.log
    EOH
  action :run
end

# set Oracle Database XE environment variables
bash "set-express-env-vars" do
  cwd "/u01/app/oracle/product/11.2.0/xe/bin"
  code ". ./oracle_env.sh"
  action :run
  user node['dev']['global_user']
  group node['dev']['global_group']
end
