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

apt_package "unixodbc" do
  action :install
end

apt_package "unzip" do
  action :install
end

apt_package "alien" do
  action :install
end

apt_package "libaio1" do
  action :install
end

# create kernel parameters
bash "create_kernel_params" do
  code <<-EOH
    cat > /etc/sysctl.d/60-oracle.conf <<-EOF
    # Oracle 11g XE kernel parameters
    fs.file-max=6815744
    net.ipv4.ip_local_port_range=9000 65500
    kernel.sem=250 32000 100 128
    # kernel.shmmax=429496729
    kernel.shmmax=107374183
    EOF
  EOH
  action :run
  not_if { ::File.exists?("/etc/sysctl.d/60-oracle.conf") }
end

# load and verify the new kernel parameters
bash "load_kernel_params" do
  code <<-EOH
    service procps start
    sudo sysctl -q fs.file-max
    sudo sysctl -q kernel.shmmax
    sudo sysctl -q net.ipv4.ip_local_port_range
    sudo sysctl -q kernel.sem 
  EOH
  action :run
end

# misc commands
bash "misc_commands" do
  code <<-EOH
    sudo ln -s /usr/bin/awk /bin/awk
    sudo mkdir /var/lock/subsys
  EOH
  action :run
  not_if { ::File.exists?("/var/lock/subsys") }
end


# misc commands
bash "misc_commands" do
  code <<-EOH
    cat > /sbin/chkconfig <<-EOF
    #!/bin/bash
    # Oracle 11gR2 XE installer chkconfig hack for Debian based Linux (by dude)
    # Only run once.
    echo "Simulating /sbin/chkconfig..."
    if [[ ! \`tail -n1 /etc/init.d/oracle-xe | grep INIT\` ]]; then
    cat >> /etc/init.d/oracle-xe <<-EOM
    #
    ### BEGIN INIT INFO
    # Provides:              OracleXE
    # Required-Start:        \\\$remote_fs \\\$syslog
    # Required-Stop:         \\\$remote_fs \\\$syslog
    # Default-Start:         2 3 4 5
    # Default-Stop:          0 1 6
    # Short-Description:     Oracle 11g Express Edition
    ### END INIT INFO
    EOM
    fi
    update-rc.d oracle-xe defaults 80 01
    EOF
    sudo chmod 755 /sbin/chkconfig
  EOH
  action :run
  not_if { ::File.exists?("/sbin/chkconfig") }
end

# copy zipped Oracle Database XE package to tmp directory
remote_file "copy-express-to-home" do 
  path "#{Chef::Config[:file_cache_path]}/#{node['dev']['express_package']}.zip"
  #path "#{node['dev']['global_user_home']}/#{node['dev']['express_package']}.zip" 
  source "file:///#{node['dev']['global_sync_folder']}/#{node['dev']['express_package']}.zip"
  checksum node['dev']['wls_pkg_checksum']
  #owner node['dev']['global_user']
  #group node['dev']['global_group']
  mode 0755
  not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/#{node['dev']['express_package']}.zip") }
end

# unzip Oracle Database XE package
bash "unzip-express" do
  cwd "#{Chef::Config[:file_cache_path]}"
  #cwd "#{node['dev']['global_user_home']}"
  code "unzip -o #{node['dev']['express_package']}.zip"
  #user node['dev']['global_user']
  action :run
  not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/Disk1/#{node['dev']['express_package']}") }
end

# covert to .deb with alien for Ubuntu
bash "convert-rpm" do
  cwd "#{Chef::Config[:file_cache_path]}/Disk1"
  #cwd "#{node['dev']['global_user_home']}/Disk1"
  code "alien --to-deb --scripts #{node['dev']['express_package']}"
  creates "#{node['dev']['express_package_deb']}"
  action :run
  not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/Disk1/#{node['dev']['express_package_deb']}") }
end

=begin
# copy static response file to tmp directory
cookbook_file "#{node['dev']['global_user_home']}/#{node['dev']['express_response_file']}" do
  source node['dev']['express_response_file']
  owner node['dev']['global_user']
  group node['dev']['global_group']
  mode 0755
end
=end

# create response file dynamically
bash "create_response_file" do
  cwd "#{Chef::Config[:file_cache_path]}/Disk1/response"
  #cwd "#{node['dev']['global_user_home']}"
  code <<-EOH
    echo \
    "ORACLE_LISTENER_PORT=#{node['dev']['express_listen_port']} \
    ORACLE_HTTP_PORT=#{node['dev']['express_http_port']} \
    ORACLE_PASSWORD=#{node['dev']['express_password']} \
    ORACLE_CONFIRM_PASSWORD=#{node['dev']['express_password']} \
    ORACLE_DBENABLE=y" \
    > #{node['dev']['express_response_file']}
  EOH
  action :run
  #user node['dev']['global_user']
  #group node['dev']['global_group']
end

=begin
directory "/xe_logs" do
  mode 0777
  action :create
  not_if { ::File.exists?("/xe_logs") }
end
=end

# install Oracle Database XE
bash "install_express" do
  cwd "#{Chef::Config[:file_cache_path]}/Disk1"
  #cwd "#{node['dev']['global_user_home']}/Disk1"
  code <<-EOH
    sudo dpkg --install #{node['dev']['express_package_deb']} \
    > /tmp/XEsilentinstall.log
  EOH
  action :run
  not_if { ::File.exists?("/etc/init.d/oracle-xe") }
end

# configure Oracle Database XE
bash "configure-express" do
  cwd "#{Chef::Config[:file_cache_path]}/Disk1"
  #cwd "#{node['dev']['global_user_home']}"
  code <<-EOH
    /etc/init.d/oracle-xe configure \
    responseFile="#{Chef::Config[:file_cache_path]}/Disk1/response/#{node['dev']['express_response_file']}" \
    >> /tmp/XEsilentinstall.log
  EOH
  action :run
end

# set Oracle Database XE environment variables
bash "set_express_env_vars" do
  cwd "/u01/app/oracle/product/11.2.0/xe/bin"
  code ". ./oracle_env.sh"
  action :run
  user node['dev']['global_user']
end

# environment variables are set properly each time you log in or open a new shell
bash "bash-login" do
code <<-EOH
  echo '. /u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh' \
  >> #{node['dev']['global_user_home']}/.bashrc
EOH
  user node['dev']['global_user']
  action :run
end
