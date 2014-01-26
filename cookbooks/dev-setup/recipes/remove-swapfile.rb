#
# Cookbook Name:: dev-setup
# Recipe:: remove-swapfile
#
# Copyright 2013, Gary A. Stafford
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

bash "remove-swap" do
  code <<-EOF
    grep -q swapfile /etc/fstab
    if [ $? -eq 0 ]; then
      echo 'swapfile found. Removing swapfile.'
      sed -i '/swapfile/d' /etc/fstab
      echo "3" > /proc/sys/vm/drop_caches
      swapoff -a
      rm -f /swapfile
    else
      echo 'No swapfile found. No changes made.'
    fi
    cat /proc/swaps
    cat /proc/meminfo | grep Swap
    EOF
  action :run
end
