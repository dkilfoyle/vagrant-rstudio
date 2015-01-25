define webmin::acl( $action ) {
  Exec {
    path    => '/bin:/sbin:/usr/sbin:/usr/bin',
    require => Package['webmin'],
    notify  => Service['webmin'],
  }
  if ( $action == delete ) {
    exec { "${action}_${name}":
      command => "sed -i 's/ $name //g' /etc/webmin/webmin.acl",
      onlyif  => "grep ' $name ' /etc/webmin/webmin.acl",
    }
  } else {}
  if ( $action == add ) {
    exec { "${action}_${name}":
      command => "sed -i 's/$/ $name /g' /etc/webmin/webmin.acl",
      unless  => "grep ' $name ' /etc/webmin/webmin.acl",
    }
  } else {}
}
