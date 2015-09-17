# Author:: Salvatore Poliandro III (sal@opsitters.com)
# Cookbook Name:: opsit_ops
# Recipe:: sshd
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

service_provider = Chef::Provider::Service::Upstart if 'ubuntu' == node['platform'] &&
  Chef::VersionConstraint.new('>= 12.04').include?(node['platform_version'])


node.set['openssh']['service_name'] = case node['platform_family']
  when 'rhel', 'fedora', 'suse', 'freebsd', 'gentoo', 'arch'
    'sshd'
  else
    'ssh'
  end

service 'ssh' do
  provider service_provider
  service_name node['openssh']['service_name']
  supports value_for_platform(
    'debian' => { 'default' => [:restart, :reload, :status] },
    'ubuntu' => {
      '8.04' => [:restart, :reload],
      'default' => [:restart, :reload, :status]
    },
    'centos' => { 'default' => [:restart, :reload, :status] },
    'redhat' => { 'default' => [:restart, :reload, :status] },
    'fedora' => { 'default' => [:restart, :reload, :status] },
    'scientific' => { 'default' => [:restart, :reload, :status] },
    'arch' => { 'default' => [:restart] },
    'default' => { 'default' => [:restart, :reload] }
  )
  action [:enable, :start]
end

if not Chef::Config[:solo]
  template "/etc/ssh/sshd_config" do
    source "sshd_config.erb"
    user "root"
    group "root"
    mode 0644
    notifies :restart, "service[ssh]"
  end
end
