Webmin and Usermin Puppet Module
================================
Webmin is a web-based interface for system administration for Unix. Using any modern web browser, you can setup user accounts, Apache, DNS, file sharing and much more. Webmin removes the need to manually edit Unix configuration files like /etc/passwd, and lets you manage a system from the console or remotely.
(To learn more about  Webmin and Usermin visit the projects website: http://www.webmin.com)

###Description
This module has been tested on Centos 6.4 and Ubuntu 12.04. It should work on any Redhat or Debian based system. It will install Webmin on port 10000 and Usermin on port 20000 and enable SSL encryption.


### Basic install
```
  include webmin
```
### Install just Webmin
This will just install webmin and not install usermin.
```
  class { 'webmin':
    usermin => 'disable',
  }
```
### Enable Config Server Firewall plugin
If you have Config Server Firewall installed, you can enable the Webmin plugin.
(visit http://www.configserver.com to learn more about csf)
```
  class { 'webmin':
    csf => true,
  }

```
### Disable Webmin.com Repository
If you you use your own package repository you can disable the default source from webmin.com
```
  class { 'webmin':
    repo => 'disable',
  }

```
### Change Ports and bind to a specific IP
```
  class { 'webmin':
    webmin_port  => '12000',
    usermin_port => '13000',
    bind_ip      => '192.168.10.1',
  }

```
###Support
Please log tickets and issues at our [Projects site](https://github.com/panaman/puppet-webmin/issues)
