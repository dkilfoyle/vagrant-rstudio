include wget
# Installs RStudio (user shiny, password shiny) and Shiny
# Change these if the version changes
# See http://www.rstudio.com/ide/download/server
# This is the standard installation (update it when a new release comes out)
# $rstudioserver = 'rstudio-server-0.98.507-amd64.deb'
# $getrstudio = "wget -nc http://download2.rstudio.org/${rstudioserver}"

# A more recent daily build
$rstudioserver = 'rstudio-server-0.98.907-amd64.deb'
$getrstudio = "wget -nc https://s3.amazonaws.com/rstudio-dailybuilds/${rstudioserver}"

# See http://www.rstudio.com/shiny/server/install-opensource
$shinyserver = 'shiny-server-1.1.0.10000-amd64.deb'
$getshiny = "wget -nc http://download3.rstudio.org/ubuntu-12.04/x86_64/${shinyserver}"

# For building shiny server from source, we need a recent cmake
$cmakeversion = '2.8.11.2'
$cmakeurl = 'http://www.cmake.org/files/v2.8/'


# Update system for r install
class update_system {   
    exec {'apt_update':
        provider => shell,
        command  => 'apt-get update;',
    }
    ->
    package {['software-properties-common','libapparmor1',
              'python-software-properties', "git",
              'upstart','dbus-x11', # required for init-checkconf testing
              'python', 'g++', 'make','vim', 'whois','mc','libcairo2-dev',
              'default-jdk', 'gdebi-core', 'libcurl4-gnutls-dev']:
      ensure  => present,
    }
    ->
    exec {'add-cran-repository':
      provider => shell,
      command  =>
      'add-apt-repository "deb http://cran.rstudio.com/bin/linux/ubuntu precise/";
      apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E084DAB9;
      apt-get update;',
    }
    -> 
    exec {'upgrade-system':
      provider => shell,
      command  =>'apt-get -y upgrade',
    }
    ->
    # Install host additions (following https://www.virtualbox.org/manual/ch04.html
    # this must be done after upgrading.
    package {'dkms':
        ensure => present,
    }    
}




# Install r base and packages
class install_r {
    package {['r-base', 'r-base-dev']:
      ensure  => present,
      require => Package['dkms'],
    }    
    ->
    exec {'install-r-packages':
        provider => shell,
        timeout  => 1200,
        command  => 'Rscript /vagrant/usefulpackages.R'
    }
}

class prepare_shiny{
    # Create rstudio_users group
    group {'rstudio_users':
        ensure => present,
    }
    ->
    # http://www.pindi.us/blog/getting-started-puppet
    user {'shiny':
        ensure  => present,
        groups   => ['rstudio_users', 'vagrant'], # adding to vagrant required for startup
        shell   => '/bin/bash',
        managehome => true,
        name    => 'shiny',
        home    => '/srv/shiny-server',
    }   
   # Setting password during user creation does not work    
   # Password shiny is public; this is for local use only
   exec {'shinypassword':
        provider => shell,
        command => 'usermod -p `mkpasswd -H md5 shiny` shiny',
     }
}

# Download and install shiny server and add users
class install_shiny_server {

    # Download shiny server
    exec {'shiny-server-download':
        provider => shell,
        require  => [Exec['install-r-packages'],
                    Package['software-properties-common',
                    'python-software-properties', 'g++']],
        command  => $getshiny,
        unless => "test -f ${shinyserver}",
    }
    ->
    # Install shiny server
    exec {'shiny-server-install':
        provider => shell,
        command  => "gdebi -n ${shinyserver}",
    }
    ->
    # Copy example shiny files
    file {'/srv/shiny-server/01_hello':
        source  => '/usr/local/lib/R/site-library/shiny/examples/01_hello',
        owner   => 'shiny',
        ensure  => 'directory',
        recurse => true,
    }   
    ->
    # Remove standard app
    file {'/srv/shiny-server/index.html':
        ensure => absent,
    } 
}

class build_shiny_server{
    # Adapted from RStudio/shiny
    # https://github.com/rstudio/shiny-server/tree/75612b466a9ea02d9ae62fc581230a81b8be1631/vagrant
    exec{'get-cmake':
        provider => shell,
        command => "wget ${cmakeurl}cmake-${cmakeversion}.tar.gz;",
        unless => "test -f cmake-${cmakeversion}.tar.gz",
    } 
    ->    
    exec{'tar-cmake':
        provider => shell,
        command => "tar xzf  cmake-${cmakeversion}.tar.gz;",
        unless => "test -d cmake-${cmakeversion}",
    }        
    ->
    exec{'make-cmake':
        provider => shell,
        command  => 
        "cd cmake-${cmakeversion};
        ./configure;
        make;
        make install;",
        unless  => '[ "$(cmake --version)" = "cmake version ${cmakeversion}" ]',
    }
    ->
    exec{'clone-git':
        provider  => shell,
        timeout   => 1800,
        command   => 
        'git clone https://github.com/rstudio/shiny-server.git;
        cd shiny-server;
        git remote add trestle https://github.com/trestletech/shiny-server.git;
        ./packaging/make-package.sh',
        unless => 'test -f /vagrant/shiny-server/bin/shiny-server',
    }
}

# install rstudio and start service
class install_rstudio_server {
    # Download rstudio server
    exec {'rstudio-server-download':
        require  => Package['r-base'],
        provider => shell,
        command  => $getrstudio,
        unless => "test -f ${rstudioserver}",
    }
    ->
    exec {'rstudio-server-install':
        provider => shell,
        command  => "gdebi -n ${rstudioserver}",
    }
}



# Make sure that both services are running
class check_services{
    service {'shiny-server':
        ensure    => running,
        require   => User['shiny'],
        hasstatus => true,
    }
    service {'rstudio-server':
        ensure    => running,
        require   => Exec['rstudio-server-install'],
        hasstatus => true,
    }
}

class startupscript{
    file { '/etc/init/makeshinylinks.conf':
       require   => Exec['shinypassword'],
       ensure => 'link',
       target => '/vagrant/makeshinylinks.conf',
    }
 ->
    exec{ 'reboot-makeshiny-links':
       provider  => shell,
       command   => '/vagrant/makeshinylinks.sh',
    }  
}



include update_system
include install_r
include build_shiny_server
include prepare_shiny
#include install_shiny_server
include install_rstudio_server
include check_services
include startupscript

