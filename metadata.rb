name             'opsit_ops'
maintainer       'OpSitters'
maintainer_email 'oss@opsitters.com'
version          '1.0.1'
license          'Apache 2.0'
description      'OpSitters recipes for some mundane tasks'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))

%w{
  apt
  chef_handler
  munin
  nrpe
  route53
  rsyslog
  yum
}.each do |cb|
  depends cb
end

%w{ debian ubuntu centos redhat }.each do |os|
  supports os
end
