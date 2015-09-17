# Author:: Salvatore Poliandro III (sal@opsitters.com)
# Cookbook Name:: opsit_ops
# Recipe:: package_tools
#
# Copyright 2015, OpSitters
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


%w{
  ethtool zsh nmap wget iotop dstat screen
  sysstat tree mtr curl
  }.each do |pkg|
  p=package pkg do
    action :nothing
  end
  p.run_action(:install)
end

if platform_family?('debian')
  include_recipe "apt"
  %w{
      htop multitail lockfile-progs vim nmon netcat-openbsd telnet ntp
      ifupdown-extra netcat-traditional whois nmap bridge-utils vlan psmisc
    }.each do |pkg|
    p=package pkg do
      action :nothing
    end
    p.run_action(:install)
  end
  if platform?("ubuntu")
    apt_package "openssl" do
      version "1.0.1-4ubuntu5.10"
      action :upgrade
    end
    apt_package "libssl1.0.0" do
      version "1.0.1-4ubuntu5.10"
      action :upgrade
    end
    apt_package "libssl-dev" do
      version "1.0.1-4ubuntu5.10"
      action :upgrade
    end
  end


  #We need to do some attrib overridin for some broken ass cookbooks.
  node.normal['nodejs']['dir'] = '/usr'
end

if platform_family?('rhel')
  include_recipe "yum"

  %w{
    vim-enhanced nc tcpdump mailx bridge-utils vconfig telnet
    }.each do |pkg|
    p=package pkg do
      action :nothing
    end
    p.run_action(:install)
  end
  # These packages have to be installed during execution and not run because
  # The repo for them wont get installed during run phase #devopsproblems
  %w{ htop multitail lockfile-progs}.each do |pkg|
    package pkg do
      action :install
    end
  end
end

# TODO
unless platform_family?('arch')
  cookbook_file "/bin/runonce" do
    source "runonce"
    owner "root"
    group "root"
    mode "755"
    action :create_if_missing
  end
end

link "/bin/env" do
  to "/usr/bin/env"
  not_if {File.exists?("/bin/env")}
end
