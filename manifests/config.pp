# == Class github_actions_runner::config
#
# This class is called from github_actions_runner for service config.
#

class github_actions_runner::config {

  $ensure_directory = $github_actions_runner::ensure ? {
    'present' => directory,
    'absent'  => absent,
  }

  file { $github_actions_runner::root_dir:
    ensure => $ensure_directory,
    mode   => '0644',
    owner  => $github_actions_runner::user,
    group  => $github_actions_runner::group,
    force  => true,
  }

}
