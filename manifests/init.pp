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
  # parameters for the class will be here
) {

  # validate parameters here



  case $::osfamily {
    'RedHat', 'Amazon': {
      case $::operatingsystemmajrelease {
        '7': {
          class { '::galaxy::install': }
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
