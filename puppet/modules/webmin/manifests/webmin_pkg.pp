class webmin::webmin_pkg (
  $webmin_port = $webmin::webmin_port,
  $csf         =  $webmin::csf,
  $ensure      = $webmin::ensure,
  $ssl         = $webmin::ssl, 
  $ssl_pkg     = $webmin::ssl_pkg,
  ) inherits webmin {
  package { 'webmin':
    ensure  => $ensure,
  }
  ensure_packages(["$ssl_pkg"])
  if ( $bind_ip != 'UNSET' ) {
    $changes = [
      "set ssl $ssl",
      "set port $webmin_port",
      "rm listen",
      "set bind $bind_ip",
    ]
  } else {
    $changes = [
      "set ssl $ssl",
      "set port $webmin_port",
      "set listen $webmin_port",
      "rm bind",
    ]
  }
  augeas { 'webmin_miniserv':
    context => "/files/etc/webmin/miniserv.conf",
    changes => $changes,
    notify  => Service['webmin'],
    require => Package['webmin'],
  }
  service { 'webmin':
    ensure    => running,
    enable    => true,
    subscribe => Package['webmin'],
  }
  if ( $csf == true ) {
    File {
      require => Package['webmin'],
      notify  => Service['webmin'],
    }
    file { '/usr/libexec/webmin/csf': 
      ensure => directory,
      owner  => '0',
      group  => 'bin',
      mode   => '0755',
    }
    file { '/usr/libexec/webmin/csf/csfimages':
      ensure => link,
      target => '/usr/local/csf/lib/webmin/csf/images',
    }
    file { '/usr/libexec/webmin/csf/index.cgi':
      ensure => link,
      target => '/usr/local/csf/lib/webmin/csf/index.cgi',
    }
    file { '/usr/libexec/webmin/csf/module.info':
      ensure => link,
      target => '/usr/local/csf/lib/webmin/csf/module.info',
    }
    webmin::acl { 'firewall':
      action => delete,
    }
    webmin::acl { 'csf':
      action => add,
    }
  } else {}
}

