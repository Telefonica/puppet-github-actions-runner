![PDK Test Unit](https://github.com/Telefonica/puppet-github-actions-runner/workflows/Run%20pdk%20test%20unit/badge.svg?branch=master)

# GitHub Actions Runner

Automatic configuration for running GitHub Actions on Debian hosts as a service

#### Table of Contents

1. [Description](#description)
2. [Limitations - OS compatibility, etc.](#limitations)
3. [Development - Guide for contributing to the module](#development)

## Description

This module will setup all of the files and configuration needed for GitHub Actions runner to work on any Debian 9 hosts.

### hiera configuration

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
github_actions_runner::instances:
  first_instance:
    labels:
      - self-hosted-custom
```

You can also override some of the keys on the instance level
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
github_actions_runner::instances:
  first_instance:
    labels:
      - self-hosted-custom1
  second_instance:
    ensure: absent
  third_instance:
    labels:
      - self-hosted-custom3
    repo_name: myrepo
    org_name: other_org
    personal_access_token: other_secret
```

In case you need to set proxy in one instance:
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
github_actions_runner::instances:
  first_instance:
    http_proxy: http://proxy.local
    https_proxy: http://proxy.local
    no_proxy: example.com
    labels:
      - self-hosted-custom1
```

In case you are using Github Enterprise Server , you can define these two parameters to specify the correct urls:
```yaml
github_actions_runner::github_domain: "https://git.example.com"
github_actions_runner::github_api: "https://git.example.com/api/v3"
```

## Limitations

Tested on Debian 9 stretch hosts only.
full list of operating systems support and requirements are described in `metadata.json` file.


If you don't specify repository name , make sure you `Personal Access Token` is org level admin.

## Development

There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things. For more information, see Puppet Forge [module contribution guide](https://puppet.com/docs/puppet/7.1/modules_publishing.html).

## License

*GitHub Actions Runner* is available under the Apache License, Version 2.0. See LICENSE file
for more info.
