# Author:: Wayne Egerer Jr. (wayne@opsitters.com)
# Cookbook Name:: opsit_ops
# Recipe:: munin_client
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


case node[:platform]
when "ubuntu"
  if !File.exist?("/etc/apt/sources.list.d/munin-backport.list")
    # Updated Munin client and plugins for debian based systems
    apt_repository "munin-backport" do
      uri "http://ppa.launchpad.net/tuxpoldo/munin/ubuntu"
      distribution node["lsb"]["codename"]
      components ["main"]
      keyserver "keyserver.ubuntu.com"
      key "D294A752"
      action :add
      notifies :run, "execute[apt-get update]", :immediately
    end
    package "munin-node" do
      action :purge
    end
    package "munin" do
      action :purge
    end
  end
end

server_hosts = Array.new
dev_server_hosts = ["192.168.36.201"]

if node.roles.include?(['opsit']['services']['munin']['role'])
  server_hosts = ["127.0.0.1"]
elsif Chef::Config[:solo] or node.chef_environment == "dev"
  server_hosts = dev_server_hosts
else
  if node['munin']['host_environment'].nil?
    node.set['munin']['server_search'] = "role:#{node['munin']['server_role']}"
  else
    node.set['munin']['server_search'] = "role:#{node['munin']['server_role']} AND chef_environment:#{node['munin']['host_environment']}"
  end
  server_nodes = search(:node, node['munin']['server_search'])
  results = server_nodes
    .sort { |a, b| a['name'] <=> b['name'] }
    .map do |nodeish|
      server_hosts << get_node_attrib(nodeish, node['munin']['host_attribute'])
    end
end

if server_hosts.empty?
  opsit_warn("No Munin Servers, will not setup client")
  return false
end

server_hosts << '127.0.0.1' unless server_hosts.include?('127.0.0.1')
node.set['munin']['server_list'] = server_hosts

# Debian/Ubuntu need a package sometimes...
case node[:platform]
when 'ubuntu', 'debian'
  package 'libwww-perl'
end

# Always run the lastest version
include_recipe 'munin::client'
package 'munin-node' do
  action :upgrade
end

# Autoconf the plugins
service_name = node['munin']['service_name']
execute 'enable_munin_plugins' do
  user 'root'
  group 'root'
  command <<-EOH
  /usr/sbin/munin-node-configure --shell | sh
  EOH
  notifies :restart, "service[#{service_name}]"
end
