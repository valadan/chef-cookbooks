#
# Cookbook Name:: dev-setup
# Recipe:: create-wls-domain
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

directory "#{products_home_tmp}/user_projects/domains/#{node['dev']['wls_domain']}" do
  owner node['dev']['global_user']
  group node['dev']['global_group']
  mode 0777
  action :create
end

bash 'set-wls-env' do
  code ". #{wl_home_tmp}/bin/setWLSEnv.sh"
  user node['dev']['global_user']
  group node['dev']['global_group']
  not_if { ::File.exists?("#{domains_home_tmp}/servers") }
  action :run
end

# create domain, create admin server, and start
# requires echo 'y' since there is no config.xml.
# installer asks to create? y/n?
# nohup runs wls in background so recipe continues to execute
bash 'create-domain' do
  cwd domains_home_tmp
  code <<-EOF
    echo 'Y' | nohup java \
    -XX:MaxPermSize=1048m -Xms512m -Xmx1024m \
    -Dweblogic.Domain=#{node['dev']['wls_domain']} \
    -Dweblogic.Name=#{node['dev']['wls_server']} \
    -Dweblogic.management.username=#{node['dev']['wls_username']} \
    -Dweblogic.management.password=#{node['dev']['wls_password']} \
    -Dweblogic.ListenPort=#{node['dev']['wls_port']} \
    -jar #{wl_home_tmp}/lib/weblogic.jar weblogic.Server > create-domain.out 2>&1 &
    exit $?
   EOF
  user node['dev']['global_user']
  group node['dev']['global_group']
  not_if { ::File.exists?("#{domains_home_tmp}/servers") }
  action :run
end

# enable tunneling py script from template
template "#{domains_home_tmp}/enable-tunneling.py" do
  source "enable-tunneling.py.erb"
  mode 0755
  owner node['dev']['global_user']
  group node['dev']['global_group']
  not_if { ::File.exists?("#{domains_home_tmp}/enable-tunneling.py") }
end

# enable tunneling with WLST
# 'java weblogic.WLST' should work but get class not found error?
bash 'enable-tunneling' do
  cwd domains_home_tmp
    code <<-EOF
      echo "enabling tunneling\n"
      sleep 55s
      nohup sh #{wl_home_tmp}/../common/bin/wlst.sh enable-tunneling.py \
      > enable-tunneling.out 2>&1 &
      echo "tunneling enabled\n"
    EOF
  user node['dev']['global_user']
  group node['dev']['global_group']
  action :run
end
