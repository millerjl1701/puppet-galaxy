# @api private
# == Class galaxy::install
#
# @param _repo_owner [String] Determines which user account should own the code repo directory based on the value of the boolean galaxy_use_separate_users. Default: gxcode
#
class galaxy::install {
  if $::galaxy::galaxy_use_separate_users {
    $_repo_owner = $::galaxy::galaxy_code_owner
  }
  else {
    $_repo_owner = $::galaxy::galaxy_runtime_user
  }

  # installation of the galaxy code from the git repository
  # ToDo: need to figure out a way for notification of galaxy server
  #   processes to restart when the current release id installed on the system
  #   does not match the galaxy_commit_id
  vcsrepo { $::galaxy::galaxy_server_dir:
    ensure     => present,
    provider   => git,
    source     => $::galaxy::galaxy_repo_url,
    revision   => $::galaxy::galaxy_commit_id,
    user       => $_repo_owner,
    submodules => false,
  }
}
