#
# Cookbook Name:: dev-setup
# Recipe:: install-env-vars
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

wl_home_tmp         = "#{node['dev']['global_user_home']}/Oracle/products/Oracle_Home/wlserver/server"
products_home_tmp   = "#{node['dev']['global_user_home']}/Oracle/products"
domains_home_tmp    = "#{node['dev']['global_user_home']}/Oracle/products/user_projects/domains/#{node['dev']['wls_domain']}"

# used next two commands to build direcoties because recursive doesn't apply rights correctly. Remain as root!
directory "#{products_home_tmp}/user_projects" do
  owner node['dev']['global_user']
  group node['dev']['global_group']
  mode 0777
  action :create
end

directory "#{products_home_tmp}/user_projects/domains" do
  owner node['dev']['global_user']
  group node['dev']['global_group']
  mode 0777
  action :create
end

bash 'set-wls-env' do
  code ". #{wl_home_tmp}/bin/setWLSEnv.sh"
  user node['dev']['global_user']
  group node['dev']['global_group']
  not_if { ::File.exists?(domains_home_tmp) }
  action :run
end

# requires echo 'y' since there is no config.xml.
# installer asks to create? y/n?
bash 'create-domain' do
  cwd "#{node['dev']['global_user_home']}/Oracle/products/user_projects/domains"
  code <<-EOF
    echo 'Y' | java -verbose \
    -XX:MaxPermSize=2048m -Xms512m -Xmx2048m \
    -Dweblogic.Domain=#{node['dev']['wls_domain']} \
    -Dweblogic.Name=#{node['dev']['wls_server']} \
    -Dweblogic.management.username=#{node['dev']['wls_username']} \
    -Dweblogic.management.password=#{node['dev']['wls_password']} \
    -Dweblogic.ListenPort=#{node['dev']['wls_port']} \
    -jar #{wl_home_tmp}/lib/weblogic.jar weblogic.Server
   EOF
  user node['dev']['global_user']
  group node['dev']['global_group']
  not_if { ::File.exists?(domains_home_tmp) }
  action :run
end

bash 'start-domain' do
  code <<-EOF
    java -verbose \
    -XX:MaxPermSize=2048m -Xms512m -Xmx2048m \
    -Dweblogic.Name=#{node['dev']['wls_server']} \
    -jar #{wl_home_tmp}/lib/weblogic.jar weblogic.Server
   EOF
  user node['dev']['global_user']
  group node['dev']['global_group']
  not_if { ::File.exists?(domains_home_tmp) }
  #action :run
end