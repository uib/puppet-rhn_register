# == Class: rhn_register
#
# This class registers a machine with RHN or a Satellite Server.  If a machine
# is already registered it does nothing unless the force parameter is set to true.
#
# === Parameters:
#
#   [*activationkey*]
#     The activation key to use when registering the system (cannot be used with
#     username and password) - This is the recommended way so that credentials
#     aren't stored in reports.
#
#   [*sslca_source*]
#     File source of the SSL CA to use.
#
#   [*force*]
#     Should the registration be forced.  Use this option with caution, setting it
#     to true will cause the rhnreg_ks command to be run every time puppet runs
#     (default: false)
#
#
#
# === Authors
#
# Raymond Kristiansen <raymond@uib.no>
# 
class rhn_register(
  $activationkey,
  $org = undef,
  $sslca_source = undef,
  $serverurl = undef,
  $sslca_path = '/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT',
  $command = '/usr/sbin/subscription-manager',
  $force = false,
) {

  if $sslca_source {
    file { $sslca_path:
      source => $sslca,
      owner => 'root',
      group => 'root',
      mode => '0600'
    }
  }


  $activation_key = $activationkey ? {
    undef   => '',
    default => " --activationkey ${activationkey}",
  }

  $use_org = $org ? {
    false   => '',
    default => "--org ${org}",
  }

  $command_args = "${activation_key}${use_org}"

  if $force and $::operatingsystem == 'RedHat' {
    exec { 'register_with_rhn':
      command => "${command} register --force --auto-attach${command_args}",
      notify => Exec['rhn_auto_attach']
    }
  } elsif $::operatingsystem == 'RedHat' {
    exec { 'register_with_rhn':
      command => "${command} register --auto-attach${command_args}",
      unless => "${command} list | /bin/grep Subscribed",
    }
  } else {
    notify { "${command} register --auto-attach${command_args}": }
  }

}
