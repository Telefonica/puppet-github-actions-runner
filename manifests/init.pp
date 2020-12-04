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
# * repo_name
#  Optional[String], actions runner repository name.
#
# * org_name
#  String, actions runner org name.
#
# * labels
#  Optional[Array[String]], A list of costum lables to add to a runner.
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
