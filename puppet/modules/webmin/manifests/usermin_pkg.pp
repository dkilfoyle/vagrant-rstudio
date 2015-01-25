class webmin::usermin_pkg (
  $usermin_port = $webmin::usermin_port,
  $ensure       = $webmin::ensure,
  $usermin      = $webmin::usermin,
  $ssl          = $webmin::ssl,
  $bind_ip      = $webmin::bind_ip,
  ) inherits webmin {
  if ( $usermin == 'enable' ) {
    package { 'usermin':
      ensure  => $ensure,
    }
    file { '/usr/share/augeas/lenses/dist/tests':
      ensure => directory,
      owner  => '0',
      group  => '0',
      mode   => '0755',
    }
    file { '/usr/share/augeas/lenses/dist/tests/test_usermin.aug':
      ensure => present,
      owner  => '0',
      group  => '0',
      mode   => '0644',
      source => 'puppet:///modules/webmin/test_usermin.aug',
      before => Augeas['usermin_miniserv'],
    }
    file { '/usr/share/augeas/lenses/dist/usermin.aug':
      ensure => present,
      owner  => '0',
      group  => '0',
      mode   => '0644',
      source => 'puppet:///modules/webmin/usermin.aug',
      before => Augeas['usermin_miniserv'],
    }
    if ( $bind_ip != 'UNSET' ) { 
      $changes = [
        "set ssl $ssl",
        "set port $usermin_port",
        "rm listen",
        "set bind $bind_ip",
      ]
    } else {
      $changes = [
        "set ssl $ssl",
        "set port $usermin_port",
        "set listen $usermin_port",
        "rm bind",
      ]
    }
    augeas { 'usermin_miniserv':
      context => "/files/etc/usermin/miniserv.conf",
      changes => $changes,
      notify  => Service['usermin'],
      require => Package['usermin'],
    }
    service { 'usermin':
      ensure    => running,
      enable    => true,
      subscribe => Package['usermin'],
    }
  } else {
    package { 'usermin':
      ensure  => absent,
    }
    file { '/usr/share/augeas/lenses/dist/tests/test_usermin.aug':
      ensure => absent,
      force  => true,
    }
    file { '/usr/share/augeas/lenses/dist/usermin.aug':
      ensure => absent,
      force  => true,
    }
  }
}
