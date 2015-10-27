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


include_recipe "chef_handler"

if node['opsit']['handlers']['json']['enabled'] == true
  chef_handler "Chef::Handler::JsonFile" do
    source "chef/handler/json_file"
    arguments :path => '/var/chef/reports'
    action :disable
  end
end



include_recipe "chef_handler"

chef_handler "Chef::Handler::JsonFile" do
  source "chef/handler/json_file"
    arguments :path => '/var/chef/reports'
    action :disable
end

chef_gem "httparty" do
  version "0.11.0"
  action :nothing
end.run_action(:install)

chef_gem "chef-handler-slack" do
  action :upgrade
end

handler_file = "/var/chef/handlers/slack.rb"
handler_source = "slack.rb"

cookbook_file handler_file do
  source handler_source
  mode "0600"
  action :nothing
end.run_action(:create)

chef_handler "Chef::Handler::SlackReporting" do
  source handler_file
  action :nothing
end.run_action(:enable)