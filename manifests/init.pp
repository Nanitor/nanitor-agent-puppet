# Class: nanitor_agent
# ===========================
#
# Full description of class nanitor_agent here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'nanitor_agent':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name sales@nanitor.com
#
# Copyright
# ---------
#
# Copyright 2017 Nanitor ehf
#
class nanitor_agent (
  $signup_command   = $nanitor_agent::params::signup_command,
  $issignup_command = $nanitor_agent::params::issignup_command,
  $signup_file      = $nanitor_agent::params::signup_file,
  $provider         = $nanitor_agent::params::provider,
)  inherits nanitor_agent::params 
{

  # install the Nanitor Agent rpm package
  package { 'nanitor-agent':
    ensure => installed,
    notify => Exec['nanitor-agent-signup'],
    provider => $provider,
  }

  file { "/root/${signup_file}":
     source => "puppet:///modules/nanitor_agent/$signup_file",
     owner => 'root',
     group => 'root',
     mode => '0644',
     require => Package['nanitor-agent'],
  }

  # Run the Nanitor Agent signup
  exec {'nanitor-agent-signup':
     command => $signup_command,
     unless  => $issignup_command,
     path  => ['/usr/lib/nanitor-agent/bin', '/usr/local/bin', '/usr/sbin', '/usr/bin'],
     notify => Service['nanitor-agent'],
     require => File["/root/$signup_file"],
  }

  # Enable start on boot and ensure that the service is running
  service {'nanitor-agent':
     enable => 'true',
     ensure => 'running',
     require => Package["nanitor-agent"],
  }
}
