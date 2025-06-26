# Class: nanitor_agent
# ===========================
#
# Installs and configures the Nanitor Agent on supported Linux systems using
# Nanitor's official repositories and a provided signup URL.
#
# This module supports both Debian-based and RHEL-based systems. It is tested
# on Debian 12 and RHEL 7+, but should also work on other systemd-based Linux
# distributions due to the statically compiled nature of the agent binary.
#
# Parameters
# ----------
#
# * `signup_url` (String)
#   The full signup URL from the Nanitor Portal. Used to register the agent
#   on first install.
#
# Example
# -------
#
#   class { 'nanitor_agent':
#     signup_url => 'https://myinstance.nanitor.net/abc123',
#   }
#
# Authors
# -------
# Nanitor Operations Team <operations@nanitor.com>
#
# Based on original work by Sverrir Arason <sverrir@sverrir.org>
#
# Copyright
# ---------
# Copyright © 2017–2025 Nanitor ehf. — All rights reserved.
#
class nanitor_agent (
  String $signup_url,
) {

  if file_exists('/opt/nanitor-agent/bin/nanitor-agent') {
    notice('Nanitor Agent binary already exists, skipping installation.')
    return()
  }

  case $facts['os']['family'] {
    'Debian': {
      package { ['gnupg', 'wget']:
        ensure => installed,
      }

      exec { 'Import Nanitor APT GPG key':
        command => 'wget -qO /etc/apt/trusted.gpg.d/nanitor.gpg.asc https://deb.nanitor.com/DEB-GPG-KEY-nanitor',
        creates => '/etc/apt/trusted.gpg.d/nanitor.gpg.asc',
        path    => ['/usr/bin', '/bin'],
      }

      file { '/etc/apt/sources.list.d/nanitor-agent.list':
        content => "deb https://deb.nanitor.com/nanitor-agent bookworm main\n",
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Exec['apt-update'],
      }

      exec { 'apt-update':
        command     => '/usr/bin/apt-get update',
        refreshonly => true,
      }

      package { 'nanitor-agent':
        ensure  => installed,
        require => Exec['apt-update'],
        notify  => Exec['nanitor-agent-signup'],
      }
    }

    'RedHat': {
      exec { 'Import Nanitor RPM GPG key':
        command => 'rpm --import https://yum.nanitor.com/nanitor-agent/RPM-GPG-KEY-nanitor',
        unless  => 'rpm -q gpg-pubkey | grep -qi nanitor',
        path    => ['/usr/bin', '/bin'],
      }

     file { '/etc/yum.repos.d/nanitor-agent.repo':
        ensure  => file,
        content => @("EOF")
          [nanitor-agent]
          name=Nanitor Agent Repository
          baseurl=https://yum.nanitor.com/nanitor-agent/rhel-7-x86_64
          enabled=1
          gpgcheck=1
          gpgkey=https://yum.nanitor.com/nanitor-agent/RPM-GPG-KEY-nanitor
          | EOF
        ,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        require => Exec['Import Nanitor RPM GPG key'],
      }

      package { 'nanitor-agent':
        ensure  => installed,
        require => File['/etc/yum.repos.d/nanitor-agent.repo'],
        notify  => Exec['nanitor-agent-signup'],
      }
    }

    default: {
      fail("Unsupported OS family: ${facts['os']['family']}")
    }
  }

  exec { 'nanitor-agent-status':
    environment => ['PATH=/opt/nanitor-agent/bin:/usr/bin:/bin', 'LANG=en_US.UTF-8', 'LC_ALL=en_US.UTF-8'],
    command     => '/opt/nanitor-agent/bin/nanitor-agent info --status 2>&1',
    returns     => [0],
    logoutput   => true,
    timeout     => 10,
    unless      => '/opt/nanitor-agent/bin/nanitor-agent info --status 2>&1 | grep -q "Signed up to a server: Yes"',

  }

  exec { 'nanitor-agent-signup':
    environment => ['PATH=/opt/nanitor-agent/bin:/usr/bin:/bin', 'LANG=en_US.UTF-8', 'LC_ALL=en_US.UTF-8'],
    logoutput   => true,
    command     => "/opt/nanitor-agent/bin/nanitor-agent signup --keyfile ${signup_url} 2>&1",
    unless      => '/opt/nanitor-agent/bin/nanitor-agent info --status 2>&1 | grep -q "Signed up to a server: Yes"',
    notify      => Service['nanitor-agent'],
    require     => Package['nanitor-agent'],
  }

  service { 'nanitor-agent':
    ensure  => running,
    enable  => true,
    require => Package['nanitor-agent'],
  }
}
