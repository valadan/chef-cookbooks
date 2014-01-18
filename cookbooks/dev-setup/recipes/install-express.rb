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

remote_file "copy-express-to-home" do 
  path "#{node['dev']['global_user_home']}/#{node['dev']['express_package']}" 
  source "file:///#{node['dev']['global_sync_folder']}/#{node['dev']['express_package']}"
  checksum node['dev']['wls_pkg_checksum']
  owner node['dev']['global_user']
  group node['dev']['global_group']
  mode 0755
  not_if { ::File.exists?(wl_home_tmp) }
end

cookbook_file "#{node['dev']['global_user_home']}/#{node['dev']['express_response_file']}" do
  source node['dev']['express_response_file']
  owner node['dev']['global_user']
  group node['dev']['global_group']
  mode 0755
end
