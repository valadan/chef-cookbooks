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

apt_package "rpm" do
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

# copy zipped Oracle Database XE package to home directory
remote_file "copy-express-to-home" do 
  path "#{node['dev']['global_user_home']}/#{node['dev']['express_package']}.zip" 
  source "file:///#{node['dev']['global_sync_folder']}/#{node['dev']['express_package']}.zip"
  checksum node['dev']['wls_pkg_checksum']
  owner node['dev']['global_user']
  group node['dev']['global_group']
  mode 0755
  not_if { ::File.exists?("#{node['dev']['global_user_home']}/#{node['dev']['express_package']}.zip") }
end

# unzip Oracle Database XE package
bash "unzip-express" do
  cwd "#{node['dev']['global_user_home']}"
  code "unzip -o #{node['dev']['express_package']}.zip"
  user node['dev']['global_user']
  action :run
    not_if { ::File.exists?("#{node['dev']['global_user_home']}/Disk1/oracle-xe-11.2.0-1.0.x86_64.rpm") }
end

# covert to .deb
bash "convert-rpm" do
  cwd "#{node['dev']['global_user_home']}/Disk1"
  code "alien --to-deb --scripts #{node['dev']['express_package']}.zip"
  creates "#{node['dev']['express_package']}.deb"
  action :run
end

=begin
# copy static response file to home directory
cookbook_file "#{node['dev']['global_user_home']}/#{node['dev']['express_response_file']}" do
  source node['dev']['express_response_file']
  owner node['dev']['global_user']
  group node['dev']['global_group']
  mode 0755
end
=end

# create response file dynamically
bash "create_response_file" do
  cwd "#{node['dev']['global_user_home']}"
  code <<-EOH
    echo \
    "ORACLE_LISTENER_PORT=#{node['dev']['express_listen_port']} \
    \nORACLE_HTTP_PORT=#{node['dev']['express_http_port']} \
    \nORACLE_PASSWORD=#{node['dev']['express_password']} \
    \nORACLE_CONFIRM_PASSWORD=#{node['dev']['express_password']} \
    \nORACLE_DBENABLE=y" \
    > #{node['dev']['express_response_file']}
    EOH
  action :run
  user node['dev']['global_user']
  group node['dev']['global_group']
end

directory "/xe_logs" do
  mode 0777
  action :create
end

=begin
# install Oracle Database XE
bash "install_express1" do
  cwd "#{node['dev']['global_user_home']}"
  code "rpm -ivh  Disk1/#{node['dev']['express_package']} > /xe_logs/XEsilentinstall.log"
  action :run
  user node['dev']['global_user']
end
=end

dpkg_package "#{node['dev']['global_user_home']}/Disk1/#{node['dev']['express_package']}.deb" do
  action :install
end

# install Oracle Database XE
bash "install_express2" do
  cwd "#{node['dev']['global_user_home']}"
  code "/etc/init.d/oracle-xe configure responseFile=#{node['dev']['express_response_file']} >> /xe_logs/XEsilentinstall.log"
  action :run
  user node['dev']['global_user']
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
  code "echo '. /u01/app/oracle/product/11.2.0/xe/bin/oracle_env.sh' >> #{node['dev']['global_user_home']}/.bashrc"
  user node['dev']['global_user']
  action :run
end