# Author:: JP Dentone (jp@opsitters.com)
# Cookbook Name:: opsit_ops
# Recipe:: handlers
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


node.set['rsyslog']['port'] = 10514
node.set['rsyslog']['nginx_port'] = 10515
node.set['rsyslog']['rate_limit_interval'] = 0
node.set['rsyslog']['imux_sock_rate_limit_interval'] = 0
node.set['rsyslog']['mark_message_period'] = 0
node.set['rsyslog']['modules'] = %w(imuxsock imklog imfile immark)
node.set['rsyslog']['repeated_msg_reduction'] = "off"
node.set['rsyslog']['logs_to_forward'] = '*.*;local3.none,local4.none,local5.none'

server_hosts = Array.new
dev_server_hosts = ["192.168.36.202","192.168.36.203"]

if node.roles.include?(['opsit']['services']['rsyslog']['role'])
  server_hosts = ["127.0.0.1"]
elsif Chef::Config[:solo] or node.chef_environment == "dev"
  server_hosts = dev_server_hosts
else
  if node['rsyslog']['host_environment'].nil?
    node.set['rsyslog']['server_search'] = "role:#{node['rsyslog']['server_role']}"
  else
    node.set['rsyslog']['server_search'] = "role:#{node['rsyslog']['server_role']} AND chef_environment:#{node['rsyslog']['host_environment']}"
  end
  server_nodes = search(:node, node['rsyslog']['server_search'])
  results = server_nodes
    .sort { |a, b| a['name'] <=> b['name'] }
    .map do |nodeish|
      server_hosts << get_node_attrib(nodeish, node['rsyslog']['host_attribute'])
    end
end

if server_hosts.empty?
  opsit_warn("No Rsyslog Servers, will not setup remote logging")
  return false
end

include_recipe 'rsyslog::default'

template "#{node['rsyslog']['config_prefix']}/rsyslog.d/00-setup-logging.conf" do
  source    "00-setup-logging.conf.erb"
  owner     'root'
  group     'root'
  mode      '0644'
  notifies  :restart, "service[#{node['rsyslog']['service_name']}]"
end

template "#{node['rsyslog']['config_prefix']}/rsyslog.d/49-remote.conf" do
  source    "49-remote.conf.erb"
  owner     'root'
  group     'root'
  mode      '0644'
  variables(:servers => server_hosts)
  notifies  :restart, "service[#{node['rsyslog']['service_name']}]"
  only_if   { node['rsyslog']['remote_logs'] }
end

file "#{node['rsyslog']['config_prefix']}/rsyslog.d/server.conf" do
  action   :delete
  notifies :reload, "service[#{node['rsyslog']['service_name']}]"
end
