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

# install environment variables
bash "install-env-vars" do
  cwd node['dev']['global_user_home']
  code <<-EOH
    grep -q JAVA_HOME .bashrc
    if [ $? -ne 0 ]; then
      echo "
export JAVA_HOME=/usr/lib/jvm/#{node['dev']['java_jdk']}
export CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/urandom
export ORACLE_HOME=#{node['dev']['global_user_home']}/Oracle/products/Oracle_Home
export WL_HOME=#{node['dev']['global_user_home']}/Oracle/products/Oracle_Home/wlserver
export PATH=/usr/lib/jvm/#{node['dev']['java_jdk']}/bin:$PATH
export PATH=#{node['dev']['global_user_home']}/Oracle/products/Oracle_Home/wlserver/server/bin:$PATH
export WL_DOMAINS=#{node['dev']['global_user_home']}/Oracle/products/user_projects/domains
export CLASSPATH=#{node['dev']['global_user_home']}/Oracle/products/Oracle_Home/wlserver/server/lib/weblogic.jar:$CLASSPATH" >> .bashrc
    fi
  EOH
  user node['dev']['global_user']
  group node['dev']['global_group']
  action :run
end

# This doesn't work as expected with chef?
bash "bash-login" do
  code ". #{node['dev']['global_user_home']}/.bashrc"
  user node['dev']['global_user']
  group node['dev']['global_group']
  action :run
end

# set varialbes temporarily for immediate use
bash "temp-install-env-vars" do
  code <<-EOH
export JAVA_HOME=/usr/lib/jvm/#{node['dev']['java_jdk']}
export CONFIG_JVM_ARGS=-Djava.security.egd=file:/dev/urandom
export ORACLE_HOME=#{node['dev']['global_user_home']}/Oracle/products/Oracle_Home
export WL_HOME=#{node['dev']['global_user_home']}/Oracle/products/Oracle_Home/wlserver
export PATH=/usr/lib/jvm/#{node['dev']['java_jdk']}/bin:$PATH
export PATH=#{node['dev']['global_user_home']}/Oracle/products/Oracle_Home/wlserver/server/bin:$PATH
export WL_DOMAINS=#{node['dev']['global_user_home']}/Oracle/products/user_projects/domains
export CLASSPATH=#{node['dev']['global_user_home']}/Oracle/products/Oracle_Home/wlserver/server/lib/weblogic.jar:$CLASSPATH
  EOH
  user node['dev']['global_user']
  group node['dev']['global_group']
  action :run
end