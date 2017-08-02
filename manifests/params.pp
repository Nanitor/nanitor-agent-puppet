# Class: nanitor_agent::params
# ===========================
#
# Params class for the Nanitor class
#
# Copyright
# ---------
#
# Copyright 2017 Nanitor ehf
#
class nanitor_agent::params {

  $config_file      = '/etc/nanitor/nanitor_agent.ini'
  $key_file         = '/root/nanitor-agent-signup-key.txt'
  $signup_command   = "/usr/lib/nanitor-agent/bin/nanitor-agent signup --config=$config_file --keyfile=$key_file"
  $issignup_command = '/usr/lib/nanitor-agent/bin/nanitor-agent is-signedup'
  $signup_file      = 'nanitor-agent-signup-key.txt'
  $yumbaseurl       = 'https://packages.nanitor.com/yum/nanitor-agent/stable/redhat/rhel-7-$basearch'
  $aptbaseurl       = 'http://packages.nanitor.com/deb/nanitor-agent/stable/' 
  $aptrelease       = 'wheezy'
  $pubkeyfile       = 'https://packages.nanitor.com/files/gpg.asc'

  case $facts['os']['family'] {
    'RedHat': {
       $provider = 'yum'

      # configure the repo holding the Nanitor Agent on Red Hat flavours
       yumrepo { 'nanitor-agent-repo':
         enabled  => 1,
         descr    => 'Nanitor Agent Stable Repo',
         baseurl  => $yumbaseurl,
         gpgkey   => $pubkeyfile,
         gpgcheck => 1,
       }
     } 
    'Debian': {
       include apt

       $provider = 'apt'

      # configure the repo holding the Nanitor Agent on Debian flavours
       apt::source { 'nanitor-agent':
         comment  => 'Nanitor agent stable',
         location => $aptbaseurl,
         release  => $aptrelease,
         repos    => 'main',
       }
       
       apt::key { 'nanitor-apt-key':
          ensure => present,
          id     => 'C514425E7C0848ACAF2FEAE786D2DD5279BFBD75',
          source => $pubkeyfile,
       }
    } 
    default: {
      fail("Nanitor Client is not supported on ${::osfamily}") 
    }
  }
}

