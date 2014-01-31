#
# Cookbook Name:: dev-setup
# Recipe:: create-wls-domain-wlst
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

# local variables
products_home_tmp   = "#{node['dev']['global_user_home']}/Oracle/products"
wl_home_tmp         = "#{node['dev']['global_user_home']}/Oracle/products/Oracle_Home/wlserver/server"
domains_home_tmp    = "#{node['dev']['global_user_home']}/Oracle/products/user_projects/domains"

# used next two commands to build nested directories because 
# recursive method doesn't seem to apply rights correctly. Remains as root...
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

# copy all WLST config files to domain home
remote_directory domains_home_tmp do
  source "wlst-create-domain"
  files_owner owner node['dev']['global_user']
  files_group node['dev']['global_group']
  files_mode 00644
  owner node['dev']['global_user']
  group node['dev']['global_group']
  mode 0755
end

# set WLS environment variables
bash 'set-wls-env' do
  code ". #{wl_home_tmp}/bin/setWLSEnv.sh"
  user node['dev']['global_user']
  group node['dev']['global_group']
  not_if { ::File.exists?("#{domains_home_tmp}/servers") }
  action :run
end

# create domain and managed server with WLST
bash 'create-domain' do
  cwd domains_home_tmp
  code "java -jar #{wl_home_tmp}/lib/weblogic.jar weblogic.Server weblogic.WLST config.py"
  user node['dev']['global_user']
  group node['dev']['global_group']
  not_if { ::File.exists?("#{domains_home_tmp}/#{node['dev']['wls_domain']}") }
  action :run
end
