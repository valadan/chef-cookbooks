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

products_home_tmp   = "#{node['dev']['global_user_home']}/Oracle/products"
wl_home_tmp         = "#{node['dev']['global_user_home']}/Oracle/products/Oracle_Home/wlserver/server"
domains_home_tmp    = "#{node['dev']['global_user_home']}/Oracle/products/user_projects/domains/#{node['dev']['wls_domain']}"

# used next two commands to build directories because recursive doesn't apply rights correctly. Remain as root!
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


remote_directory Chef::Config[:file_cache_path] do
  source "wlst-create-domain"
  owner node['dev']['global_user']
  group node['dev']['global_group']
  mode 0777  
end

bash 'create-domain' do
  cwd Chef::Config[:file_cache_path]
  code "java weblogic.WLST config.py"
  user node['dev']['global_user']
  group node['dev']['global_group']
  not_if { ::File.exists?(domains_home_tmp) }
  action :run
end

=begin
Dir.foreach("#{node['dev']['wls_response_file']}/wlst-create-domain") do |item|
  next if item == '.' or item == '..'
  cookbook_file "#{Chef::Config[:file_cache_path]}/item" do
    source "#{node['dev']['wls_response_file']}/wlst-create-domain"
    owner node['dev']['global_user']
    group node['dev']['global_group']
    not_if { ::File.exists?(wl_home_tmp) }
  end
end

cookbook_file "#{Chef::Config[:file_cache_path]}/#{node['dev']['wls_response_file']}" do
  source "#{node['dev']['wls_response_file']}/wlst-create-domain"
  owner node['dev']['global_user']
  group node['dev']['global_group']
  not_if { ::File.exists?(wl_home_tmp) }
end
=end

