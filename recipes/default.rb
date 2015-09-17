# Author:: Salvatore Poliandro III (sal@opsitters.com)
# Cookbook Name:: opsit_ops
# Recipe:: default
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


# This should only be present during a bootstrap run.
# These tags may also already be applied, as we try and set them in 3 places
# but chef/bootstrap tag support is buggy
begin
  init_tags = IO.readlines("/etc/chef/opsit/init_tags")
rescue
  init_tags = Array.new
end

init_tags.each do |tag_name|
  tag_name.gsub(/\s+/, "")
  tag_name = tag_name.scan(/[[:print:]]/).join
  if tag_name.length > 1
    Chef::Log.warn("OPSITTERS: Applying INIT TAG : #{tag_name}")
    tag("#{tag_name}") unless tagged?("#{tag_name}")
  end
end

file "/etc/chef/opsit/init_tags" do
  action :delete
end
