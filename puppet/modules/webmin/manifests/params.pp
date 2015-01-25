class webmin::params {
  $webmin_port  = '10000'
  $usermin_port = '20000'
  $repo         = 'webmin.com'
  $proxy        = 'absent'
  $csf          = false
  $ensure       = 'latest'
  $usermin      = 'enable'
  $ssl          = '1'
  $ssl_pkg      = $osfamily ? {
    'RedHat' => 'perl-Net-SSLeay',
    'Debian' => 'libnet-ssleay-perl',
  }
  $bind_ip      = 'UNSET'
}
