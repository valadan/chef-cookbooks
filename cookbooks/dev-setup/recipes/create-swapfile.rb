#
# Cookbook Name:: dev-setup
# Recipe:: create-swapfile
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

bash "create-swap" do
  code <<-EOF
    grep -q swapfile /etc/fstab
    if [ $? -ne 0 ]; then
      echo 'swapfile not found. Adding swapfile.'
      fallocate -l #{node['dev']['swap_size_mb']}M /swapfile
      chmod 600 /swapfile
      mkswap /swapfile
      swapon /swapfile
      echo '/swapfile none swap defaults 0 0' >> /etc/fstab
    else
      echo 'swapfile found. No changes made.'
    fi
    cat /proc/swaps
    cat /proc/meminfo | grep Swap
    EOF
  action :run
end
