# GitHub Actions Runner

Automatic configuration for running GitHub Actions on Debian hosts as a service

#### Table of Contents

1. [Description](#description)
2. [Limitations - OS compatibility, etc.](#limitations)
3. [Development - Guide for contributing to the module](#development)

### Description

This module will setup all of the files and configuration needed for GitHub Actions runner to work on any Debian 9 hosts.


#### hiera configuration

This module supports configuration through hiera. The following example
creates repository level Actions runners. 
```yaml
github_actions_runner::ensure: present
github_actions_runner::base_dir_name: '/data/actions-runner'
github_actions_runner::package_name: 'actions-runner-linux-x64'
github_actions_runner::package_ensure: '2.272.0'
github_actions_runner::repository_url: 'https://github.com/actions/runner/releases/download'
github_actions_runner::org_name: 'github_org'
github_actions_runner::personal_access_token: 'PAT'
github_actions_runner::user: 'root'
github_actions_runner::group: 'root'
github_actions_runner::labels:
  - self-hosted-custom
```

### Limitations

Tested on Debian 9 stretch hosts only.
full list of operating systems support and requirements are described in `metadata.json` file.


If you don't specify repository name , make sure you `Personal Access Token` is org level admin.

### Development

This module development should be just like any other puppet modules.
Use PDK to run unit tests: `pdk test unit`
