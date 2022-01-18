![PDK Test Unit](https://github.com/Telefonica/puppet-github-actions-runner/workflows/Run%20pdk%20test%20unit/badge.svg?branch=master)

# GitHub Actions Runner

Automatic configuration for running GitHub Actions as a service

#### Table of Contents

1. [Description](#description)
    - [Hiera configuration examples](#hiera-configuration-examples)
    - [Github Enterprise examples](#github-enterprise-examples)
2. [Limitations - OS compatibility, etc.](#limitations)
3. [Development - Guide for contributing to the module](#development)

## Description

This module will setup all of the files and configuration needed for GitHub Actions runner to work on Debian (Stretch and Buster) and CentOS7 hosts.

### hiera configuration examples

This module supports configuration through hiera.

#### Creating an organization level Actions runner

```yaml
github_actions_runner::ensure: present
github_actions_runner::base_dir_name: '/data/actions-runner'
github_actions_runner::package_name: 'actions-runner-linux-x64'
github_actions_runner::package_ensure: '2.277.1'
github_actions_runner::repository_url: 'https://github.com/actions/runner/releases/download'
github_actions_runner::org_name: 'my_github_organization'
github_actions_runner::personal_access_token: 'PAT'
github_actions_runner::user: 'root'
github_actions_runner::group: 'root'
github_actions_runner::instances:
  example_org_instance:
    labels:
      - self-hosted-custom
```

Note, your `personal_access_token` has to contain the `admin:org` permission.

#### Creating an additional repository level Actions runner
```yaml
github_actions_runner::instances:
  example_org_instance:
    labels:
      - self-hosted-custom1
  example_repo_instance:
    repo_name: myrepo
    labels:
      - self-hosted-custom2
```

Note, your `personal_access_token` has to contain the `repo` permission.

#### Instance level overwrites
```yaml
github_actions_runner::instances:
  example_org_instance:
    ensure: absent
    labels:
      - self-hosted-custom1
  example_repo_instance:
    org_name: overwritten_orgnization
    repo_name: myrepo
    labels:
      - self-hosted-custom2
```

#### Adding a global proxy and overwriting an instance level proxy
```yaml
github_actions_runner::http_proxy: http://proxy.local
github_actions_runner::https_proxy: http://proxy.local
github_actions_runner::instances:
  example_org_instance:
    http_proxy: http://instance_specific_proxy.local
    https_proxy: http://instance_specific_proxy.local
    no_proxy: example.com
    labels:
      - self-hosted-custom1
```

### Github Enterprise examples
To use the module with Github Enterprise Server, you have to define these parameters:
```yaml
github_actions_runner::github_domain: "https://git.example.com"
github_actions_runner::github_api: "https://git.example.com/api/v3"
```

In addition to the runner configuration examples above, you can also configure runners
on the enterprise level by setting a value for `enterprise_name`, for example:
```yaml
github_actions_runner::ensure: present
github_actions_runner::base_dir_name: '/data/actions-runner'
github_actions_runner::package_name: 'actions-runner-linux-x64'
github_actions_runner::package_ensure: '2.277.1'
github_actions_runner::repository_url: 'https://github.com/actions/runner/releases/download'
github_actions_runner::enterprise_name: 'enterprise_name'
github_actions_runner::personal_access_token: 'PAT'
github_actions_runner::user: 'root'
github_actions_runner::group: 'root'
github_actions_runner::instances:
```

Note, your `personal_access_token` has to contain the `admin:enterprise` permission.

### Update PATH used by Github Runners

By default, puppet will not modify the values that the runner scripts create when
the runner is set.

In case you need to use another value of paths in the environment variable PATH,
you can define through hiera. For example:

- For all runners defined:
  ```yaml
  github_actions_runner::path:
    - /usr/local/bin
    - /usr/bin
    - /bin
    - /my/own/path
  ```
- For just a specific runner:
  ```yaml
  github_actions_runner::instances:
    example_org_instance:
      path:
        - /usr/local/bin
        - /usr/bin
        - /bin
        - /my/own/path
      labels:
        - self-hosted-custom
  ```

## Limitations

Tested on Debian 9 (stretch), Debian 10 (buster) and CentOS7 hosts.
Full list of operating systems support and requirements are described in `metadata.json` file.

## Development

There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things. For more information, see Puppet Forge [module contribution guide](https://puppet.com/docs/puppet/7.1/modules_publishing.html).

## License

*GitHub Actions Runner* is available under the Apache License, Version 2.0. See LICENSE file
for more info.
