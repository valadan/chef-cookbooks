#
# Cookbook Name:: dev-setup
# Attributes:: default
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

# General settings
  default['dev']['global_sync_folder']      = 'artifacts'
  default['dev']['global_user']             = 'vagrant'
  default['dev']['global_group']            = 'vagrant'
  default['dev']['global_user_home']        = "/home/#{default['dev']['global_user']}"

# JDK install settings
  default['dev']['java_jdk_package']        = 'jdk-7u45-linux-x64.tar.gz'
  default['dev']['java_jdk']                = 'jdk1.7.0_45'
  default['dev']['java_jdk_pkg_checksum']   = 'f2eae4d81c69dfa79d02466d1cb34db2b628815731ffc36e9b98f96f46f94b1a'
  default['dev']['java_install_jdk']        = 'install_jdk.sh'
  default['dev']['java_install_env_vars']   = 'create_env_vars.sh'
  
# Swapfile settings
  default['dev']['swap_create']             = 'create_swapfile.sh'
  default['dev']['swap_size_mb']            = '1024'
  default['dev']['swap_remove']             = 'remove_swapfile.sh'

# WLS install settings
  default['dev']['wls_package']             = 'wls_121200.jar'
  default['dev']['wls_pkg_checksum']        = 'e6efe85f3aec005ce037bd740f512e23c136635c63e20e02589ee0d0c50c065c'
  default['dev']['wls_response_file']       = 'wls.rsp'
  default['dev']['wls_install_loc_file']    = 'oraInst.loc'

# WLS Domain/Server install settings
  default['dev']['wls_domain']              = 'development'
  default['dev']['wls_server']              = 'applications'
  default['dev']['wls_username']            = 'weblogic'
  default['dev']['wls_password']            = 'weblogic1'
  default['dev']['wls_port']                = 7709

# Database Express Edition install settings
  default['dev']['express_package']         = 'oracle-xe-11.2.0-1.0.x86_64'
  default['dev']['express_pkg_checksum']    = 'b5039fad2e4f92c68778dcabbd0b4622a6cb025f25f7d6222f9e9de53ebab531'
  default['dev']['express_response_file']   = 'xe.rsp'
  default['dev']['express_listen_port']     = 1521
  default['dev']['express_http_port']       = 8380
  default['dev']['express_password']        = 'express1'
