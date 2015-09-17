# Author:: Salvatore Poliandro III (sal@opsitters.com)
# Cookbook Name:: opsit_ops
# Recipe:: carbon_client
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



server_hosts = Array.new
dev_server_hosts = ["192.168.36.204"]

if node.roles.include?(['opsit']['services']['carbon']['role'])
  server_hosts = ["127.0.0.1"]
elsif Chef::Config[:solo] or node.chef_environment == "dev"
  server_hosts = dev_server_hosts
else
  if node['carbon']['host_environment'].nil?
    node.set['carbon']['server_search'] = "role:#{node['carbon']['server_role']}"
  else
    node.set['carbon']['server_search'] = "role:#{node['carbon']['server_role']} AND chef_environment:#{node['carbon']['host_environment']}"
  end
  server_nodes = search(:node, node['carbon']['server_search'])
  results = server_nodes
    .sort { |a, b| a['name'] <=> b['name'] }
    .map do |nodeish|
      server_hosts << get_node_attrib(nodeish, node['carbon']['host_attribute'])
    end
end

if server_hosts.empty?
  opsit_warn("No Carbon Servers, will not setup carbon or statsd")
  return false
end

if node['carbon']['server_ip'].nil?
  carbon_host = server_hosts.sample
else
  if not server_hosts.include?(node['carbon']['server_ip'])
    carbon_host = server_hosts.sample
  else
    carbon_host = node['carbon']['server_ip']
  end
end

template "/usr/local/bin/hit_carbon" do
  source "send_carbon_stats.sh"
  owner "root"
  group "root"
  mode 0755
  variables({
    :ip => carbon_host,
    :port => 2003,
  })
end

template "/usr/local/bin/hit_statsd" do
  source "send_statsd_stats.sh"
  owner "root"
  group "root"
  mode 0755
  variables({
    :ip => carbon_host,
    :port => 8125,
  })
end

node.set['carbon']['server_ip'] = carbon_host
