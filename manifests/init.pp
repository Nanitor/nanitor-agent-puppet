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
  case $facts['os']['family'] {
    'Debian': {
      include ::apt

      # configure the repo holding the Nanitor Agent on Debian flavours
      apt::source { 'nanitor-agent':
        comment  => 'Nanitor agent stable',
        location => 'https://deb.nanitor.com/nanitor-agent',
        release  => 'bookworm',
        repos    => 'main',
        key      => {
          'name'   => 'nanitor.gpg',
           source => 'https://deb.nanitor.com/DEB-GPG-KEY-nanitor.gpg',
        },
        notify_update  => true,
      }

      Apt::Source['nanitor-agent'] -> Package['nanitor-agent']
    }

    'RedHat': {
      yumrepo { 'nanitor-agent-repo':
        enabled  => 1,
        descr    => 'Nanitor Agent Stable Repo',
        baseurl  => 'https://yum.nanitor.com/nanitor-agent/rhel-7-x86_64',
        gpgkey   => 'https://yum.nanitor.com/nanitor-agent/RPM-GPG-KEY-nanitor',
        gpgcheck => 1,
      }
    }

    default: {
      fail("Unsupported OS family: ${facts['os']['family']}")
    }
  }

  package { 'nanitor-agent':
    ensure => latest,
  }

  exec { 'nanitor-agent-signup':
    environment => ['PATH=/opt/nanitor-agent/bin:/usr/bin:/bin', 'LANG=en_US.UTF-8', 'LC_ALL=en_US.UTF-8'],
    logoutput   => true,
    command     => "/opt/nanitor-agent/bin/nanitor-agent signup --keyfile ${signup_url} 2>&1",
    unless      => '/opt/nanitor-agent/bin/nanitor-agent is-signedup',
    notify      => Service['nanitor-agent'],
    require     => Package['nanitor-agent'],
  }

  service { 'nanitor-agent':
    ensure  => running,
    enable  => true,
    require => [Package['nanitor-agent'], Exec['nanitor-agent-signup']],
  }
}
