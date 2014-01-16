#
# Cookbook Name:: dev-setup
# Recipe:: default
#
# Copyright 2013, Gary A. Stafford
#
# All rights reserved - Do Not Redistribute
#

include_recipe	create-swapfile
include_recipe	install-java
include_recipe	install-env-vars
include_recipe	install-wls
include_recipe	create-wls-domain
#include_recipe	remove-swapfile