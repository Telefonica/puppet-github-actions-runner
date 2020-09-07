# == Class github_actions_runner::install
#
# This class is called from actions_runner for package and service installation.
#
class github_actions_runner::install {
  $archive_name =  "${github_actions_runner::package_name}-${github_actions_runner::package_ensure}.tar.gz"
  $source = "${github_actions_runner::repository_url}/v${github_actions_runner::package_ensure}/${archive_name}"

  archive { $archive_name:
    ensure       => $github_actions_runner::ensure,
    path         => "/tmp/${archive_name}",
    source       => $source,
    extract      => true,
    extract_path => $github_actions_runner::root_dir,
    creates      => "${github_actions_runner::root_dir}/bin",
    cleanup      => true,
    require      => File[$github_actions_runner::root_dir],
  }

  file { "${github_actions_runner::root_dir}/configure_install_runner.sh":
    ensure  => $github_actions_runner::ensure,
    mode    => '0755',
    owner   => $github_actions_runner::user,
    group   => $github_actions_runner::group,
    content => epp('github_actions_runner/configure_install_runner.sh.epp'),
    notify  => Exec['run_configure_install_runner.sh'],
    require => Archive[$archive_name],
  }

  exec { 'run_configure_install_runner.sh':
    cwd         => $github_actions_runner::root_dir,
    command     => "${github_actions_runner::root_dir}/configure_install_runner.sh",
    refreshonly => true
  }

  systemd::unit_file { 'github-actions-runner.service':
    ensure  => $github_actions_runner::ensure,
    content => epp('github_actions_runner/github-actions-runner.service.epp'),
    require => [File["${github_actions_runner::root_dir}/configure_install_runner.sh"],Exec['run_configure_install_runner.sh']],
    notify  => Service['github-actions-runner'],
  }

}
