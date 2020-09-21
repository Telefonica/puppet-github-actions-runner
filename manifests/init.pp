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
# * hostname
#  String, actions runner name.
#
# * personal_access_token
# String, GitHub PAT with admin permission on the repositories or the origanization .
#
# * package_name
# String, GitHub Actions runner offical package name.
#
# * package_ensure
# String, GitHub Actions runner version to be used.
#
# * repository_url
# String, URL to download GutHub actions runner.
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
  String                    $hostname = $::facts['hostname'],
  Optional[Array[String]]   $labels = undef,
  Optional[String]          $repo_name = undef,

) {

  $root_dir = "${github_actions_runner::base_dir_name}-${github_actions_runner::package_ensure}"

  if $github_actions_runner::labels {
    $flattend_labels_list=join($github_actions_runner::labels, ',')
    $assured_labels="--labels ${flattend_labels_list}"
  } else {
    $assured_labels = undef
  }

  $url = $github_actions_runner::repo_name ? {
    undef => "https://github.com/${github_actions_runner::org_name}",
    default => "https://github.com/${github_actions_runner::org_name}/${github_actions_runner::repo_name}",
  }

  $token_url = $github_actions_runner::repo_name ? {
    undef => "https://api.github.com/repos/${github_actions_runner::org_name}/actions/runners/registration-token",
    default => "https://api.github.com/repos/${github_actions_runner::org_name}/${github_actions_runner::repo_name}/actions/runners/registration-token",
  }

  class { '::github_actions_runner::config': }
  -> class { '::github_actions_runner::install': }
  ~> class { '::github_actions_runner::service': }

}
