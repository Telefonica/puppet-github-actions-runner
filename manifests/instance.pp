# == Define github_actions_runner::instance
#
#  Configure and deploy actions runners instances
#
# * ensure
#  Enum, Determine if to add or remove the resource.
#
# * org_name
#  String, actions runner org name.(Default: Value set by github_actions_runner Class)
#
# * personal_access_token
# String, GitHub PAT with admin permission on the repositories or the origanization.(Default: Value set by github_actions_runner Class)
#
# * user
# String, User to be used in Service and directories.(Default: Value set by github_actions_runner Class)
#
# * group
# String, Group to be used in Service and directories.(Default: Value set by github_actions_runner Class)
#
# * repo_name
#  Optional[String], actions runner repository name.
#
# * labels
#  Optional[Array[String]], A list of costum lables to add to a runner.
#

define github_actions_runner::instance (
  Enum['present', 'absent'] $ensure                = 'present',
  String                    $org_name              = $github_actions_runner::org_name,
  String                    $personal_access_token = $github_actions_runner::personal_access_token,
  String                    $user                  = $github_actions_runner::user,
  String                    $group                 = $github_actions_runner::group,
  Optional[Array[String]]   $labels                = undef,
  Optional[String]          $repo_name             = undef,

) {

  if $labels {
    $flattend_labels_list=join($labels, ',')
    $assured_labels="--labels ${flattend_labels_list}"
  } else {
    $assured_labels = undef
  }

  $url = $repo_name ? {
    undef => "https://github.com/${org_name}",
    default => "https://github.com/${org_name}/${repo_name}",
  }

  $token_url = $repo_name ? {
    undef => "https://api.github.com/repos/${org_name}/actions/runners/registration-token",
    default => "https://api.github.com/repos/${org_name}/${repo_name}/actions/runners/registration-token",
  }

  $archive_name =  "${github_actions_runner::package_name}-${github_actions_runner::package_ensure}.tar.gz"
  $source = "${github_actions_runner::repository_url}/v${github_actions_runner::package_ensure}/${archive_name}"

  $ensure_instance_directory = $ensure ? {
    'present' => directory,
    'absent'  => absent,
  }

  file { "${github_actions_runner::root_dir}/${name}":
    ensure  => $ensure_instance_directory,
    mode    => '0644',
    owner   => $user,
    group   => $group,
    force   => true,
    require => File[$github_actions_runner::root_dir],
  }

  archive { $archive_name:
    ensure       => $ensure,
    path         => "/tmp/${archive_name}",
    source       => $source,
    extract      => true,
    extract_path => "${github_actions_runner::root_dir}/${name}",
    creates      => "${github_actions_runner::root_dir}/${name}/bin",
    cleanup      => true,
    require      => File["${github_actions_runner::root_dir}/${name}"],
  }

  file { "${github_actions_runner::root_dir}/${name}/configure_install_runner.sh":
    ensure  => $ensure,
    mode    => '0755',
    owner   => $user,
    group   => $group,
    content => epp('github_actions_runner/configure_install_runner.sh.epp'),
    notify  => Exec['run_configure_install_runner.sh'],
    require => Archive[$archive_name],
  }

  exec { 'run_configure_install_runner.sh':
    cwd         => "${github_actions_runner::root_dir}/${name}",
    command     => "${github_actions_runner::root_dir}/${name}/configure_install_runner.sh",
    refreshonly => true
  }

  systemd::unit_file { 'github-actions-runner-${name}.service':
    ensure  => $ensure,
    content => epp('github_actions_runner/github-actions-runner.service.epp'),
    require => [File["${github_actions_runner::root_dir}/${name}/configure_install_runner.sh"],Exec['run_configure_install_runner.sh']],
    notify  => Service["github-actions-runner-${name}"],
  }

  $ensure_service = $ensure ? {
    'present' => running,
    'absent'  => stopped,
  }

  $enable_service = $ensure ? {
    'present' => true,
    'absent'  => false,
  }

  service { "github-actions-runner-${name}":
    ensure  => $ensure_service,
    enable  => $enable_service,
    require => Class['systemd::systemctl::daemon_reload'],
  }

}
