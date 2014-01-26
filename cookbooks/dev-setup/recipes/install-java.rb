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

remote_file "copy-jdk-to-cache" do 
  path "#{Chef::Config[:file_cache_path]}/#{node['dev']['java_jdk_package']}" 
  source "file:///#{node['dev']['global_sync_folder']}/#{node['dev']['java_jdk_package']}"
  checksum node['dev']['java_jdk_pkg_checksum']
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
  code "sudo tar -zxf #{node['dev']['java_jdk_package']} -C /usr/lib/jvm"
  action :run
  not_if { ::File.exists?("/usr/lib/jvm/#{node['dev']['java_jdk']}/bin/java") }
end

bash "install-java" do
  code <<-EOH
    # priority value
    priority=20000

    # path to binaries directory
    binaries=/usr/bin

    # path to libraries directory
    libraries=/usr/lib

    # path to new java version
    javapath=$libraries/jvm/#{node['dev']['java_jdk']}

    # install and config java web start (java)
    sudo update-alternatives --install $binaries/java java \
      $javapath/jre/bin/java $priority
    sudo update-alternatives --auto java

    # install and config java web start (javaws)
    sudo update-alternatives --install $binaries/javaws javaws \
      $javapath/jre/bin/javaws $priority
    sudo update-alternatives --auto javaws

    # install and config java compiler (javac)
    sudo update-alternatives --install $binaries/javac javac \
      $javapath/bin/javac $priority
    sudo update-alternatives --auto javac

    # install and config java archive tool (jar)
    sudo update-alternatives --install $binaries/jar jar \
      $javapath/bin/jar $priority
    sudo update-alternatives --auto jar

    # jar signing and verification tool (jarsigner)
    sudo update-alternatives --install $binaries/jarsigner jarsigner \
      $javapath/bin/jarsigner $priority
    sudo update-alternatives --auto jarsigner

    # install and config java tool for generating api documentation in html  (javadoc)
    sudo update-alternatives --install $binaries/javadoc javadoc \
      $javapath/bin/javadoc $priority
    sudo update-alternatives --auto javadoc

    # install and config java disassembler (javap)
    sudo update-alternatives --install $binaries/javap javap \
      $javapath/bin/javap $priority
    sudo update-alternatives --auto javap

    # install and config file that creates c header files and c stub (javah)
    sudo update-alternatives --install $binaries/javah javah \
      $javapath/bin/javah $priority
    sudo update-alternatives --auto javah

    # jexec utility executes command inside the jail (jexec)
    sudo update-alternatives --install $binaries/jexec jexec \
      $javapath/lib/jexec $priority
    sudo update-alternatives --auto jexec

    # install and config file to run applets without a web browser (appletviewer)
    sudo update-alternatives --install $binaries/appletviewer appletviewer \
      $javapath/bin/appletviewer $priority
    sudo update-alternatives --auto appletviewer

    # install and config java plugin for linux (mozilla-javaplugin.so)
    if [ -f '$libraries/mozilla/plugins/libjavaplugin.so mozilla-javaplugin.so' ]; then
      sudo update-alternatives --install \
        $libraries/mozilla/plugins/libjavaplugin.so mozilla-javaplugin.so \
        $javapath/jre/lib/amd64/libnpjp2.so $priority
      sudo update-alternatives --auto mozilla-javaplugin.so
    else
      echo 'Mozilla Firefox not found. Java Plugin for Linux will not be installed.'
    fi
  EOH
  action :run
  #not_if { ::File.exists?("/usr/lib/jvm/jdk1.7.0_45/bin/java") }
end
