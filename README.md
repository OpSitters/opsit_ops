opsit_ops Cookbook
================

This cookbook has recipes for some of the more routine setups that we use.


Requirements
============
- apt cookbook
- chef_handler cookbook
- munin cookbook
- nrpe cookbook
- route53 cookbook
- rsyslog cookbook
- yum cookbook


Attributes
==========
**This is only a portion of the attributes, check out the attribute files for more info**

###Statsd/Carbon Server Role
````ruby
default['opsit']['services']['carbon']['role'] = 'carbon'
````

###Munin Server Role
```ruby
default['opsit']['services']['munin']['role'] = 'munin'
```

###Nagios Server Role
```ruby
default['opsit']['services']['nagios']['role'] = 'nagios'
```

###Rsyslog server role
```ruby
default['opsit']['services']['rsyslog']['role'] = 'logstash'
```

###route 53 Zone ID
```ruby
default['opsit']['route53']['zone_id'] = nil
```


###SSH Service Port
```ruby
default['opsit']['sshd']['port'] = "22"
```


Recipes
==========
###opsit_ops::attributes
Dumps the `node['opsit']` attributes to a json file in /etc/chef/opsit

###opsit_ops::default
Applies any INIT_TAGS which are pulled from `/etc/chef/opsit/init_tags`.  This is really only usefull during bootstrap as it deletes the init_tags file on first run

###opsit_ops::delete_validation
Removes any validator key used during bootstrap

###opsit_ops::handlers
Installs a bunch of optional handlers, controlled by the `node['opsit']['handlers]` attribute hash

###opsit_ops::munin_client
Configures a munin client without having all the dependancies of the munin cookbook

###opsit_ops::nrpe
Configures a munin client without having all the dependancies of the nagios cookbook

###opsit_ops::package_prune
Prunes a bunch of packages we at OpSitters file lame

###opsit_ops::package_tools
Installs a bunch of packages we at OpSitters fine awesome


###opsit_ops::rsyslog
Configures rsyslog to log to a remote rsyslog server


###opsit_ops::sshd
Enables two factor SSHD authentication on platforms that support it.


Usage
=====
include opsit_ops in a node's run list or from another recipe, and call the specific recipe for what you want to do. Check the releases page for production ready versions.


Contributing
==============
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github


Authors
=======
- Original Author: Salvatore Poliandro III <sal@opsitters.com>
- Author: JP Dentone <jp@opsitters.com>
- Author: Wayne Egerer <wayne@opsitters.com>
