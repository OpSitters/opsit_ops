# Author:: Salvatore Poliandro III (sal@opsitters.com)
# Cookbook Name:: opsit_ops
# Recipe:: package_prune
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


if platform_family?('debian')
  if node[:platform]=="ubuntu"
    %w{apparmor whoopsie}.each do |srv|
      service(srv) do
        action [:stop, :disable]
        ignore_failure true
      end
    end
  end

  %w{popularity-contest whoopsie unity-lens-shopping}.each do |pkg|
    package pkg do
      action :purge
      ignore_failure true
    end
  end
end

if platform_family?('rhel')
  %w{autofs avahi-daemon bluetooth cpuspeed cups gpm haldaemon messagebus}.each do |srv|
    service(srv) do
      action [:stop, :disable]
      ignore_failure true
    end
  end
  begin
    if Mixlib::ShellOut.new("getenforce").run_command.stdout != "Disabled\n"
      execute("setenforce 0") { ignore_failure true }.run_action(:run)
    end
  rescue
    Chef::Log.debug("OPSITTERS: SELinux Tools not found...")
  end
end
