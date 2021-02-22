# Class: github_actions_runner
# ===========================
#
# Manages actions_runner service and configuration
# All default Can be view at the `modules/actions_runner/data/common.yaml` file.
#
# Parameters
# ----------
#
# * ensure
#  Enum, Determine if to add or remove the resource.
#
# * base_dir_name
#  Absolutepath, Location of the base directory for actions runner to be installed.
#
# * org_name
#  String, actions runner org name.
#
# * personal_access_token
# String, GitHub PAT with admin permission on the repositories or the origanization.
#
# * package_name
# String, GitHub Actions runner offical package name.
#
# * package_ensure
# String, GitHub Actions runner version to be used.
#
# * repository_url
# String, URL to download GitHub actions runner.
#
# * user
# String, User to be used in Service and directories.
#
# * group
# String, Group to be used in Service and directories.
#
# * instances
# Hash[String, Hash], Github Runner Instances to be managed.
#
# * github_domain
# String, Base URL for Github Domain.
#
# * github_api
# String, Base URL for Github API.
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

class github_actions_runner (
  Enum['present', 'absent'] $ensure,
  Stdlib::Absolutepath      $base_dir_name,
  String                    $org_name,
  String                    $personal_access_token,
  String                    $package_name,
  String                    $package_ensure,
  String                    $repository_url,
  String                    $user,
  String                    $group,
  Hash[String, Hash]        $instances,
  String                    $github_domain,
  String                    $github_api,
  Optional[String]          $http_proxy = undef,
  Optional[String]          $https_proxy = undef,
  Optional[String]          $no_proxy = undef,
) {

  $root_dir = "${github_actions_runner::base_dir_name}-${github_actions_runner::package_ensure}"

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

  create_resources(github_actions_runner::instance, $github_actions_runner::instances)

}
