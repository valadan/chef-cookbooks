#
# Cookbook Name:: dev-setup
# Recipe:: install-java
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

remote_file "copy-jdk-to-home" do 
  path "#{Chef::Config[:file_cache_path]}/#{node['dev']['java_jdk_package']}" 
  source "file:///#{node['dev']['global_sync_folder']}/#{node['dev']['java_jdk_package']}"
  #not_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/#{node['dev']['java_jdk_package']}") }
  checksum node['dev']['java_jdk_pkg_checksum']
  #owner node['dev']['global_user']
  #group node['dev']['global_group']
  mode 0755
end

# make jvm directory
bash "make_jvm_dir" do
  code <<-EOH
    sudo mkdir /usr/lib/jvm
    sudo chmod +x /usr/lib/jvm
  EOH
  action :run
  not_if { ::File.exists?("/usr/lib/jvm") }
end

# untar JDK package
bash "untar-jdk" do
  cwd Chef::Config[:file_cache_path]
  #cwd "#{node['dev']['global_user_home']}"
  code "sudo tar -zxf #{Chef::Config[:file_cache_path]}/#{node['dev']['java_jdk_package']} -C /usr/lib/jvm"
  #user node['dev']['global_user']
  action :run
  not_if { ::File.exists?("/usr/lib/jvm/jdk1.7.0_45/bin/java") }
end

cookbook_file "#{Chef::Config[:file_cache_path]}/#{node['dev']['java_install_jdk']}" do
  source node['dev']['java_install_jdk']
  #owner node['dev']['global_user']
  #group node['dev']['global_group']
  mode 0755
end

bash "install-java" do
  code "sh #{Chef::Config[:file_cache_path]}/#{node['dev']['java_install_jdk']}"
  #user node['dev']['global_user']
  action :run
  not_if { ::File.exists?("/usr/lib/jvm/jdk1.7.0_45/bin/java") }
end

=begin
file "#{Chef::Config[:file_cache_path]}/#{node['dev']['java_jdk_package']}" do 
  action :delete
end

file "#{Chef::Config[:file_cache_path]}/#{node['dev']['java_install_jdk']}" do 
  action :delete
end
=end
