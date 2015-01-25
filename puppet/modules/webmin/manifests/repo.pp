class webmin::repo (
  $repo         = $webmin::repo,
  $proxy        = $webmin::proxy,
  ) inherits webmin {
  if ( $repo == 'webmin.com' ) and ( $osfamily == 'RedHat' ) {
    yumrepo { 'webmin':
      mirrorlist => 'http://download.webmin.com/download/yum/mirrorlist',
      enabled    => '1',
      proxy      => $proxy,
      gpgcheck   => '1',
      gpgkey     => 'http://www.webmin.com/jcameron-key.asc',
      descr      => 'Webmin Distribution',
    }
  } elsif ( $repo == 'webmin.com' ) and ( $osfamily == 'Debian' ) {
    #apt::key { 'webmin':
    #  key        => '1B24BE83',
    #  key_source => 'http://www.webmin.com/jcameron-key.asc',
    #} ->
    apt::source { 'webmin_mirror':
      location    => 'http://webmin.mirror.somersettechsolutions.co.uk/repository',
      release     => 'sarge',
      repos       => 'contrib',
      key         => '1B24BE83',
      key_source  => 'http://www.webmin.com/jcameron-key.asc',
      include_src => false,
    } 
    apt::source { 'webmin_main':
      location    => 'http://download.webmin.com/download/repository',
      release     => 'sarge',
      repos       => 'contrib',
      key         => '1B24BE83',
      key_source  => 'http://www.webmin.com/jcameron-key.asc',
      include_src => false,
    }
  } else {}
}
