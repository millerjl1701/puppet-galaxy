# @api private
# == Class galaxy::config
#
# This private class is called from galaxy for manging either static and/or mutable configurations.
#
class galaxy::config {
  if $::galaxy::galaxy_manage_static_setup {
    file { [ $::galaxy::galaxy_config_dir, $::galaxy::galaxy_shed_tools_dir ]:
      ensure => directory,
      owner  => 'root',
      group  => 'root',
      mode   => '0755',
    }
    # Install additional Galaxy config files (static) ... references galaxy_config_files but that appears to be an enpty set??

    # Install additional Galaxy config files (template) ... references galaxy_config_templates but that appears to be an empty set??

    file { $::galaxy::galaxy_config_file:
      ensure  => present,
      owner   => root,
      group   => root,
      mode    => '0644',
      content => template('galaxy/galaxy.ini.erb'),
    }

    # Collect Galaxy conditional dependency requirement strings similar to what is in tasks/dependencies.yml

    # Install Galaxy conditional dependencies similar to what is in tasks/dependencies.yml
  }

  # mutable configurations
  file { [ $::galaxy::galaxy_mutable_config_dir, $::galaxy::galaxy_tool_dependency_dir ]:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # Instantiate mutable configuration files similar to what is in tasks/mutable_setup.yml

}
