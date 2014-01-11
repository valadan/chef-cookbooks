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

cookbook_file "#{node['dev']['global_user_home']}/#{node['dev']['java_install_env_vars']}" do
  source node['dev']['java_install_env_vars']
  owner node['dev']['global_user']
  group node['dev']['global_group']
  mode 0755
end

bash "install-env-vars" do
  code "sh #{node['dev']['global_user_home']}/#{node['dev']['java_install_env_vars']}"
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

bash "temp_install_env_vars" do
  code <<-EOH
    export JAVA_HOME='/usr/lib/jvm/#{node['dev']['java_jdk']}'
    export PATH='$JAVA_HOME/bin:$PATH'
    export CONFIG_JVM_ARGS='-Djava.security.egd=file:/dev/urandom'
    export ORACLE_HOME='$HOME/Oracle/products/Oracle_Home'
    export WL_HOME='$ORACLE_HOME/wlserver'
    export PATH='$WL_HOME/server/bin:$PATH'
    export WL_DOMAINS="#{node['dev']['global_user_home']}/Oracle/products/user_projects/domains"
    export CLASSPATH='$WL_HOME/server/lib/weblogic.jar:$CLASSPATH'
    EOH
  action :run
end