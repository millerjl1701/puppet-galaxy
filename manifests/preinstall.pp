# == Class galaxy::preinstall
#
# This private class is called from galaxy for install and handles tasks that
# need to occur prior to the galaxy installation.
#
class galaxy::preinstall {
  user { $::galaxy::galaxy_code_owner:
    ensure     => present,
    comment    => 'Galaxy Code',
    home       => '/opt/galaxy',
    managehome => true,
    system     => true,
  }

  user { $::galaxy::galaxy_runtime_user:
    ensure     => present,
    comment    => 'Galaxy Server',
    home       => '/var/opt/galaxy',
    managehome => true,
    system     => true,
  }

  if $::galaxy::galaxy_manage_git {
    package{ $::galaxy::git_package_name:
      ensure => present,
    }
  }
}
