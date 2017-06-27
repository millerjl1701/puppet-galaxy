# @api private
# == Class galaxy::preinstall
#
# This private class is called from galaxy for install and handles tasks that
# need to occur prior to the galaxy installation.
#
class galaxy::preinstall {
  if $::galaxy::galaxy_use_separate_users {
    user { $::galaxy::galaxy_code_owner:
      ensure     => present,
      comment    => 'Galaxy Code',
      home       => $::galaxy::galaxy_base_dir,
      managehome => false,
      system     => true,
    }
    file { $::galaxy::galaxy_base_dir:
      ensure  => directory,
      owner   => $::galaxy::galaxy_code_owner,
      group   => $::galaxy::galaxy_code_owner,
      mode    => '0755',
      require => User[$::galaxy::galaxy_code_owner],
    }
    user { $::galaxy::galaxy_runtime_user:
      ensure     => present,
      comment    => 'Galaxy Server',
      home       => $::galaxy::galaxy_runtime_dir,
      managehome => false,
      system     => true,
    }
    file {  $::galaxy::galaxy_runtime_dir:
      ensure  => directory,
      owner   => $::galaxy::galaxy_runtime_user,
      group   => $::galaxy::galaxy_runtime_user,
      mode    => '0755',
      require => User[$::galaxy::galaxy_runtime_user],
    }
  }
  else {
    user { $::galaxy::galaxy_runtime_user:
      ensure     => present,
      comment    => 'Galaxy Server',
      home       => $::galaxy::galaxy_base_dir,
      managehome => false,
      system     => true,
    }
    file { [ $::galaxy::galaxy_base_dir, $::galaxy::galaxy_runtime_dir ]:
      ensure  => directory,
      owner   => $::galaxy::galaxy_runtime_user,
      group   => $::galaxy::galaxy_runtime_user,
      mode    => '0755',
      require => User[$::galaxy::galaxy_runtime_user],
    }
  }

  if $::galaxy::galaxy_manage_git {
    package{ $::galaxy::git_package_name:
      ensure => present,
    }
  }
}
