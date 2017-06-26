# Class: galaxy
# ===========================
#
# This is the main public class for the galaxy module.
#
# Parameters
# ----------
#
# * `sample parameter`
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
class galaxy (
  Stdlib::Absolutepath  $galaxy_server_dir           = '/opt/galaxy/server',
  Stdlib::Absolutepath  $galaxy_config_dir           = '/opt/galaxy/config',
  Stdlib::Absolutepath  $galaxy_config_file          = '/opt/galaxy/config/galaxy.ini',
  Stdlib::Absolutepath  $galaxy_mutable_config_dir   = '/var/opt/galaxy/config',
  Stdlib::Absolutepath  $galaxy_tool_dependency_dir  = '/opt/galaxy/server/dependencies',
  Stdlib::Absolutepath  $galaxy_venv_dir             = '/opt/galaxy/server/.venv',
  Stdlib::Absolutepath  $galaxy_mutable_data_dir     = '/var/opt/galaxy/data',
  Stdlib::Absolutepath  $galaxy_shed_tools_dir       = '/opt/galaxy/shed_tools',
  Stdlib::Absolutepath  $galaxy_shed_tool_conf_file  = '/var/opt/galaxy/config/shed_tool_conf.xml',
  Stdlib::Absolutepath  $galaxy_requirements_file    = '/opt/galaxy/server/lib/galaxy/dependencies/pinned-requirements.txt',
  String                $galaxy_code_owner           = 'gxcode',
  String                $galaxy_runtime_user         = 'galaxy',
  String                $galaxy_commit_id            = 'release_17.05',
  String                $galaxy_repo_url             = 'https://github.com/galaxyproject/galaxy.git',
  Boolean               $galaxy_manage_git           = true,
  String                $git_package_name            = 'git',
  Boolean               $galaxy_manage_clone         = true,
  Boolean               $galaxy_force_checkout       = false,
  Boolean               $galaxy_manage_download      = false,
  Boolean               $galaxy_manage_static_setup  = true,
  Boolean               $galaxy_manage_mutable_setup = true,
  Boolean               $galaxy_manage_database      = true,
  Boolean               $galaxy_fetch_dependencies   = true,
  Boolean               $galaxy_manage_errordocs     = false,
) {

  case $::osfamily {
    'RedHat', 'Amazon': {
      case $::operatingsystemmajrelease {
        '7': {
          class { '::galaxy::preinstall': }
          -> class { '::galaxy::install': }
          -> class { '::galaxy::config': }
          ~> class { '::galaxy::service': }
          -> Class['::galaxy']
        }
        default: {
          fail("unsupported operating system and release hit in galaxy::params:  ${::operatingsystem} ${::operatingsystemmajrelease}")
        }
      }
    }
    default: {
      fail("${::operatingsystem} not supported")
    }
  }
}
