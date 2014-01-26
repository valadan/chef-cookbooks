#
# Cookbook Name:: dev-setup
# Recipe:: wls
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
#

wl_home_tmp = "#{ENV['ORACLE_HOME']}/wlserver/server"

# create inventory file
directory "#{node['dev']['global_user_home']}/oui_inventory" do
  owner node['dev']['global_user']
  group node['dev']['global_group']
  mode 0755
  action :create
  not_if { ::File.exists?(wl_home_tmp) }
end

# create wls location file
bash 'create-location-file' do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    echo "
inventory_loc=#{node['dev']['global_user_home']}/oui_inventory
inst_group=node['dev']['global_user']" > oraInst.loc
  EOH
  user node['dev']['global_user']
  group node['dev']['global_group']
  action :run
  not_if { ::File.exists?(wl_home_tmp) }
end

# copy response file to cache
cookbook_file "#{Chef::Config[:file_cache_path]}/#{node['dev']['wls_response_file']}" do
  source node['dev']['wls_response_file']
  owner node['dev']['global_user']
  group node['dev']['global_group']
  not_if { ::File.exists?(wl_home_tmp) }
end

# copy wls jar to cache
remote_file "copy-wls-to-cache" do 
  path "#{Chef::Config[:file_cache_path]}/#{node['dev']['wls_package']}" 
  source "file:///#{node['dev']['global_sync_folder']}/#{node['dev']['wls_package']}"
  checksum node['dev']['wls_pkg_checksum']
  mode 0755
  not_if { ::File.exists?(wl_home_tmp) }
end

# cannot run as root, will fail.
bash "install-wls" do
  cwd Chef::Config['file_cache_path']
  code <<-EOF
    java \
    -jar #{node['dev']['wls_package']} -silent \
    -response #{node['dev']['wls_response_file']} \
    -invPtrLoc #{node['dev']['wls_install_loc_file']}
    EOF
  user node['dev']['global_user']
  group node['dev']['global_group']
  not_if { ::File.exists?(wl_home_tmp) }
  action :run
end
