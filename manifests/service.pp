# == Class github_actions_runner::service
#
# This class is meant to be called from github_actions_runner.
# It ensure the service is running.
#
class github_actions_runner::service {

  $ensure_service = $github_actions_runner::ensure ? {
    'present' => running,
    'absent'  => stopped,
  }

  $enable_service = $github_actions_runner::ensure ? {
    'present' => true,
    'absent'  => false,
  }

  service { 'github-actions-runner':
    ensure  => $ensure_service,
    enable  => $enable_service,
    require => Class['systemd::systemctl::daemon_reload'],
  }

}
