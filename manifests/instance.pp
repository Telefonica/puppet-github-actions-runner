# == Define github_actions_runner::instance
#
#  Configure and deploy actions runners instances
#
# * ensure
#  Enum, Determine if to add or remove the resource.
#
# * org_name
# Optional[String], org name for organization level runners. (Default: Value set by github_actions_runner Class)
#
# * enterprise_name
#  Optional[String], enterprise name for global runners. (Default: Value set by github_actions_runner Class)
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
# * hostname
# String, actions runner name.
#
# * instance_name
# String, The instance name as part of the instances Hash.
#
# * http_proxy
# Optional[String], Proxy URL for HTTP traffic. More information at https://docs.github.com/en/actions/hosting-your-own-runners/using-a-proxy-server-with-self-hosted-runners.
#
# * https_proxy
# Optional[String], Proxy URL for HTTPS traffic. More information at https://docs.github.com/en/actions/hosting-your-own-runners/using-a-proxy-server-with-self-hosted-runners
#
# * no_proxy
# Optional[String], Comma separated list of hosts that should not use a proxy. More information at https://docs.github.com/en/actions/hosting-your-own-runners/using-a-proxy-server-with-self-hosted-runners
#
# * repo_name
# Optional[String], actions runner repository name.
#
# * labels
# Optional[Array[String]], A list of costum lables to add to a runner.
#
# * path
# Optional[Array[String]], List of paths to be used as PATH env in the instance runner. If not defined, file ".path" will be kept as created
#                          by the runner scripts. (Default: Value set by github_actions_runner Class)
#
# * env
# Optional[Hash[String, String]], List of variables to be used as env variables in the instance runner.
#                                 If not defined, file ".env" will be kept as created
#                                 by the runner scripts. (Default: Value set by github_actions_runner Class)
#
define github_actions_runner::instance (
  Enum['present', 'absent']      $ensure                = 'present',
  String[1]                      $personal_access_token = $github_actions_runner::personal_access_token,
  String[1]                      $user                  = $github_actions_runner::user,
  String[1]                      $group                 = $github_actions_runner::group,
  String[1]                      $hostname              = $::facts['hostname'],
  String[1]                      $instance_name         = $title,
  String[1]                      $github_domain         = $github_actions_runner::github_domain,
  String[1]                      $github_api            = $github_actions_runner::github_api,
  Optional[String[1]]            $http_proxy            = $github_actions_runner::http_proxy,
  Optional[String[1]]            $https_proxy           = $github_actions_runner::https_proxy,
  Optional[String[1]]            $no_proxy              = $github_actions_runner::no_proxy,
  Optional[Array[String[1]]]     $labels                = undef,
  Optional[String[1]]            $enterprise_name       = $github_actions_runner::enterprise_name,
  Optional[String[1]]            $org_name              = $github_actions_runner::org_name,
  Optional[String[1]]            $repo_name             = undef,
  Optional[Array[String]]        $path                  = $github_actions_runner::path,
  Optional[Hash[String, String]] $env                   = $github_actions_runner::env,
) {

  if $labels {
    $flattend_labels_list=join($labels, ',')
    $assured_labels="--labels ${flattend_labels_list}"
  } else {
    $assured_labels = ''
  }

  if $org_name {
    if $repo_name {
      $token_url = "${github_api}/repos/${org_name}/${repo_name}/actions/runners/registration-token"
      $url = "${github_domain}/${org_name}/${repo_name}"
    } else {
      $token_url = "${github_api}/orgs/${org_name}/actions/runners/registration-token"
      $url = "${github_domain}/${org_name}"
    }
  } elsif $enterprise_name {
    $token_url = "${github_api}/enterprises/${enterprise_name}/actions/runners/registration-token"
    $url = "${github_domain}/enterprises/${enterprise_name}"
  } else {
    fail("Either 'org_name' or 'enterprise_name' is required to create runner instances")
  }

  $archive_name =  "${github_actions_runner::package_name}-${github_actions_runner::package_ensure}.tar.gz"
  $source = "${github_actions_runner::repository_url}/v${github_actions_runner::package_ensure}/${archive_name}"

  $ensure_instance_directory = $ensure ? {
    'present' => directory,
    'absent'  => absent,
  }

  file { "${github_actions_runner::root_dir}/${instance_name}":
    ensure  => $ensure_instance_directory,
    mode    => '0644',
    owner   => $user,
    group   => $group,
    force   => true,
    require => File[$github_actions_runner::root_dir],
  }

  archive { "${instance_name}-${archive_name}":
    ensure       => $ensure,
    path         => "/tmp/${instance_name}-${archive_name}",
    user         => $user,
    group        => $group,
    source       => $source,
    extract      => true,
    extract_path => "${github_actions_runner::root_dir}/${instance_name}",
    creates      => "${github_actions_runner::root_dir}/${instance_name}/bin",
    cleanup      => true,
    require      => File["${github_actions_runner::root_dir}/${instance_name}"],
  }

  file { "${github_actions_runner::root_dir}/${name}/configure_install_runner.sh":
    ensure  => $ensure,
    mode    => '0755',
    owner   => $user,
    group   => $group,
    content => epp('github_actions_runner/configure_install_runner.sh.epp', {
      personal_access_token => $personal_access_token,
      token_url             => $token_url,
      instance_name         => $instance_name,
      root_dir              => $github_actions_runner::root_dir,
      url                   => $url,
      hostname              => $hostname,
      assured_labels        => $assured_labels,
    }),
    notify  => Exec["${instance_name}-run_configure_install_runner.sh"],
    require => Archive["${instance_name}-${archive_name}"],
  }

  if $ensure == 'present' {
      exec { "${instance_name}-check-runner-configured":
        user    => $user,
        cwd     => '/srv',
        command => 'true',
        unless  => "test -f ${github_actions_runner::root_dir}/${instance_name}/runsvc.sh",
        path    => ['/bin', '/usr/bin'],
        notify  => Exec["${instance_name}-run_configure_install_runner.sh"],
      }
  }

  exec { "${instance_name}-ownership":
    user        => $user,
    cwd         => $github_actions_runner::root_dir,
    command     => "/bin/chown -R ${user}:${group} ${github_actions_runner::root_dir}/${instance_name}",
    refreshonly => true,
    path        => ['/bin', '/usr/bin'],
    subscribe   => Archive["${instance_name}-${archive_name}"],
    onlyif      => "test -d ${github_actions_runner::root_dir}/${instance_name}"
  }

  exec { "${instance_name}-run_configure_install_runner.sh":
    user        => $user,
    cwd         => "${github_actions_runner::root_dir}/${instance_name}",
    command     => "${github_actions_runner::root_dir}/${instance_name}/configure_install_runner.sh",
    refreshonly => true,
    path        => ['/bin', '/usr/bin'],
    onlyif      => "test -d ${github_actions_runner::root_dir}/${instance_name}"
  }

  $content_path = $path ? {
      undef   => undef,
      default => epp('github_actions_runner/path.epp', {
        paths => $path,
      })
  }

  file { "${github_actions_runner::root_dir}/${name}/.path":
    ensure  => $ensure,
    mode    => '0644',
    owner   => $user,
    group   => $group,
    content => $content_path,
    require => [Archive["${instance_name}-${archive_name}"],
                Exec["${instance_name}-run_configure_install_runner.sh"],
    ],
    notify  => Systemd::Unit_file["github-actions-runner.${instance_name}.service"]
  }

  $content_env = $env ? {
      undef   => undef,
      default => epp('github_actions_runner/env.epp', {
        envs => $env,
      })
  }

  file { "${github_actions_runner::root_dir}/${name}/.env":
    ensure  => $ensure,
    mode    => '0644',
    owner   => $user,
    group   => $group,
    content => $content_env,
    require => [Archive["${instance_name}-${archive_name}"],
                Exec["${instance_name}-run_configure_install_runner.sh"],
    ],
    notify  => Systemd::Unit_file["github-actions-runner.${instance_name}.service"]
  }

  $active_service = $ensure ? {
    'present' => true,
    'absent'  => false,
  }

  $enable_service = $ensure ? {
    'present' => true,
    'absent'  => false,
  }

  systemd::unit_file { "github-actions-runner.${instance_name}.service":
    ensure  => $ensure,
    enable  => $enable_service,
    active  => $active_service,
    content => epp('github_actions_runner/github-actions-runner.service.epp', {
      instance_name => $instance_name,
      root_dir      => $github_actions_runner::root_dir,
      user          => $user,
      group         => $group,
      http_proxy    => $http_proxy,
      https_proxy   => $https_proxy,
      no_proxy      => $no_proxy,
    }),
    require => [File["${github_actions_runner::root_dir}/${instance_name}/configure_install_runner.sh"],
                File["${github_actions_runner::root_dir}/${instance_name}/.path"],
                Exec["${instance_name}-run_configure_install_runner.sh"]],
  }

}
