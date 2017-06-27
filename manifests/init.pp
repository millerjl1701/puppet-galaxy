# Class: galaxy
# ===========================
#
# This is the main public class for the galaxy module.
#
# @param galaxy_base_dir [Stdlib::Absolutepath] Directory where the galaxy will be installed and configured. Default value: /opt/galaxy
# @param galaxy_code_owner [String] Name of the user for that will own the galaxy code directory. Default value: gxcode
# @param galaxy_manage_git [Boolean] Whether to manage the git package resource. Default value: true
# @param galaxy_manage_venv [Boolean] Whether to manage creation of the python 2.7 virtual environment for galaxy. Default value: true
# @param galaxy_runtime_dir [Stdlib::Absolutepath] Directory for runtime files for the galaxy server. Default value: /var/opt/galaxy
# @param galaxy_runtime_user [String] User account name that is the galaxy runtime user. Default value: galaxy
# @param galaxy_use_separate_users [Boolean] Whether to use separate user accounts for the galaxy code directory and the galaxy runtime. Default value: true
# @param galaxy_venv_dir [Stdlib::Absolutepath] Directory where the galaxy python virtual environment lives. Default value: /opt/galaxy/server/.venv
# @param git_package_name [String] Specifies the name of the git package to manage. Default value: git
#
class galaxy (
  Stdlib::Absolutepath  $galaxy_base_dir             = '/opt/galaxy',
  Stdlib::Absolutepath  $galaxy_config_dir           = '/opt/galaxy/config',
  Stdlib::Absolutepath  $galaxy_config_file          = '/opt/galaxy/config/galaxy.ini',
  Stdlib::Absolutepath  $galaxy_requirements_file    = '/opt/galaxy/server/lib/galaxy/dependencies/pinned-requirements.txt',
  Stdlib::Absolutepath  $galaxy_server_dir           = '/opt/galaxy/server',
  Stdlib::Absolutepath  $galaxy_shed_tools_dir       = '/opt/galaxy/shed_tools',
  Stdlib::Absolutepath  $galaxy_tool_dependency_dir  = '/opt/galaxy/server/dependencies',
  Stdlib::Absolutepath  $galaxy_venv_dir             = '/opt/galaxy/server/.venv',
  Stdlib::Absolutepath  $galaxy_runtime_dir          = '/var/opt/galaxy',
  Stdlib::Absolutepath  $galaxy_mutable_config_dir   = '/var/opt/galaxy/config',
  Stdlib::Absolutepath  $galaxy_shed_tool_conf_file  = '/var/opt/galaxy/config/shed_tool_conf.xml',
  Stdlib::Absolutepath  $galaxy_mutable_data_dir     = '/var/opt/galaxy/data',
  Boolean               $galaxy_use_separate_users   = true,
  String                $galaxy_code_owner           = 'gxcode',
  String                $galaxy_runtime_user         = 'galaxy',
  String                $galaxy_commit_id            = 'release_17.05',
  String                $galaxy_repo_url             = 'https://github.com/galaxyproject/galaxy.git',
  Boolean               $galaxy_manage_git           = true,
  String                $git_package_name            = 'git',
  Boolean               $galaxy_manage_venv          = true,
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
