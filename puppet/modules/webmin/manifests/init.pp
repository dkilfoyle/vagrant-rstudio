class webmin (
  $webmin_port  = $webmin::params::webmin_port,
  $usermin_port = $webmin::params::usermin_port,
  $repo         = $webmin::params::repo,
  $proxy        = $webmin::params::proxy,
  $csf          = $webmin::params::csf,
  $ensure       = $webmin::params::ensure,
  $usermin      = $webmin::params::usermin,
  $ssl          = $webmin::params::ssl,
  $ssl_pkg      = $webmin::params::ssl_pkg,
  $bind_ip      = $webmin::params::bind_ip,
  ) inherits webmin::params {
  if ( $osfamily =~ /(RedHat|Debian)/ )  {
    class{'webmin::repo': }
    ->
    class{'webmin::webmin_pkg': }
    ->
    class{'webmin::usermin_pkg': }
  } else {}
}
