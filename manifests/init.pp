# Class: galaxy
# ===========================
#
# Full description of class galaxy here.
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
) inherits ::galaxy::params {

  # validate parameters here

  class { '::galaxy::install': }
  -> class { '::galaxy::config': }
  ~> class { '::galaxy::service': }
  -> Class['::galaxy']
}
