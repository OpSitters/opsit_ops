# Author:: Salvatore Poliandro III (sal@opsitters.com)
# Cookbook Name:: opsit_ops
# Recipe:: nrpe
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


node.set['nrpe']['multi_environment_monitoring'] = 0
node.set['nrpe']['dont_blame_nrpe'] = 1
node.set['nrpe']['command_timeout'] = 90
node.set['nrpe']['using_solo_search'] = true
node.set['nrpe']['server_role'] = node['nagios']['server_role']

case node['platform_family']
when 'rhel', 'fedora'
  if node['kernel']['machine'] == 'i686'
    node.set['nrpe']['plugin_dir'] = '/usr/lib/nagios/plugins'
  else
    node.set['nrpe']['plugin_dir'] = '/usr/lib64/nagios/plugins'
  end
else
  node.set['nrpe']['plugin_dir'] = '/usr/lib/nagios/plugins'
end

server_hosts = Array.new
dev_server_hosts = ["192.168.36.200"]

if node.roles.include?(node['opsit']['services']['nagios']['role'])
  server_hosts = ["127.0.0.1"]
elsif Chef::Config[:solo] or node.chef_environment == "dev"
  server_hosts = dev_server_hosts
else
  if node['nagios']['host_environment'].nil?
    node.set['nagios']['server_search'] = "role:#{node['nagios']['server_role']}"
  else
    node.set['nagios']['server_search'] = "role:#{node['nagios']['server_role']} AND chef_environment:#{node['nagios']['host_environment']}"
  end
  server_nodes = search(:node, node['nagios']['server_search'])
  results = server_nodes
    .sort { |a, b| a['name'] <=> b['name'] }
    .map do |nodeish|
      server_hosts << get_node_attrib(nodeish, node['nagios']['host_attribute'])
    end
end

if server_hosts.empty?
  opsit_warn("No Nagios Servers, will not setup NRPE")
  return false
end

node.set['nrpe']['allowed_hosts'] = server_hosts

  if node['platform_family'] == "rhel"
    node.set['nrpe']['packages'] = %w(nrpe nagios-plugins-disk nagios-plugins-load nagios-plugins-procs nagios-plugins-users nagios-plugins-all nagios-plugins-nrpe)
  end

include_recipe "nrpe"

# Check the current system load average
nrpe_check "check_load" do
  command "#{node['nrpe']['plugin_dir']}/check_load"
  warning_condition '5'
  critical_condition '10'
  action :add
end

# Check all local disks and ensure NFS is not stale.
nrpe_check 'check_all_disks' do
  command "#{node['nrpe']['plugin_dir']}/check_disk"
  warning_condition '8%'
  critical_condition '5%'
  parameters '-L'
  action :add
end

# Check for excessive users.  This command relies on the service definition to
# define what the warning/critical levels and attributes are
nrpe_check 'check_users' do
  command "#{node['nrpe']['plugin_dir']}/check_users"
  warning_condition '3'
  critical_condition '5'
  action :add
end
