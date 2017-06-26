# == Class galaxy::params
#
# This class is meant to be called from galaxy.
# It sets variables according to platform.
#
class galaxy::params {
  case $::osfamily {
    'RedHat', 'Amazon': {
      case $::operatingsystemmajrelease {
        '7': {

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
