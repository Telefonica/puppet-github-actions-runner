# Class: github_actions_runner
# ===========================
#
# Manages actions_runner service and configuration
# All defaults can be viewed in the `modules/actions_runner/data/common.yaml` file.
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
# * enterprise_name
#  String, enterprise name for global runners
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
# * path
# Optional[Array[String]], List of paths to be used as PATH env in the instance runner.
#                          If not defined, file ".path" will be kept as created by the runner scripts. Default value: undef
#
# * env
# Optional[Hash[String, String]], List of variables to be used as env variables in the instance runner.
#                                 If not defined, file ".env" will be kept as created
#                                 by the runner scripts. (Default: Value set by github_actions_runner Class)
#
class github_actions_runner (
  Enum['present', 'absent']      $ensure,
  Stdlib::Absolutepath           $base_dir_name,
  String[1]                      $personal_access_token,
  String[1]                      $package_name,
  String[1]                      $package_ensure,
  String[1]                      $repository_url,
  String[1]                      $user,
  String[1]                      $group,
  Hash[String[1], Hash]          $instances,
  String[1]                      $github_domain,
  String[1]                      $github_api,
  Optional[String[1]]            $enterprise_name = undef,
  Optional[String[1]]            $org_name = undef,
  Optional[String[1]]            $http_proxy = undef,
  Optional[String[1]]            $https_proxy = undef,
  Optional[String[1]]            $no_proxy = undef,
  Optional[Array[String]]        $path = undef,
  Optional[Hash[String, String]] $env = undef,
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
