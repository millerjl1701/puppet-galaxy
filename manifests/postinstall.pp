# @api private
# == Class galaxy::postinstall
#
# @param _venv_owner [String] Determines which user account should own the virtual environment. Default: gxcode
#
class galaxy::postinstall {
  if $::galaxy::galaxy_use_separate_users {
    $_venv_owner = $::galaxy::galaxy_code_owner
  }
  else {
    $_venv_owner = $::galaxy::galaxy_runtime_user
  }

  if $::galaxy::galaxy_manage_venv {
    exec { 'install_pip_via_curl_to_get_latest':
      command => '/bin/curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | /bin/python',
      creates => '/bin/pip',
    }
    -> package { 'virtualenv':
      ensure   => present,
      provider => 'pip',
    }
    -> exec { 'create_galaxy_virtualenv':
      command => "/bin/virtualenv -p python ${::galaxy::galaxy_venv_dir}",
      user    => $_venv_owner,
      creates => "${::galaxy::galaxy_venv_dir}/bin/activate",
    }
    ~> exec { 'install_galaxy_virtualenv_wheels':
      command     => "${::galaxy::galaxy_venv_dir}/bin/pip --log ${::galaxy::galaxy_venv_dir}/pip.log install --index-url ${::galaxy::galaxy_wheels_repo_url} -r ${::galaxy::galaxy_requirements_file}",
      refreshonly => true,
      timeout     => 0,
      user        => $_venv_owner,
      cwd         => $::galaxy::galaxy_venv_dir,
    }
  }
}
