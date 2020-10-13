# Reference

## Table of Contents

**Classes**

* [`github_actions_runner`](#github_actions_runner)

**Defines**

* [`github_actions_runner::instance`](#github_actions_runner_instance)

## Classes

### github_actions_runner

Guides the basic setup and installation of GitHub actions runner on your system.

You can read more about self-hosted actions runner [here](https://docs.github.com/en/free-pro-team@latest/actions/hosting-your-own-runners/about-self-hosted-runners)

#### Parameters

The following parameters are available in the `github_actions_runner` class.

##### `ensure`

Data type: `Enum['present', 'absent']]`
Enum, Determine if to add or remove the resource.

##### `base_dir_name`

Data type: `Absolutepath`
Location of the base directory for actions runner to be installed.

##### `org_name`

Data type: `String`

actions runner github organization name.

##### `hostname`

Data type: `String`

actions runner name

Default value: $::facts['hostname']

##### `personal_access_token`

Data type: `String`

GitHub Personal Access Token with admin permission on the repositories or the organization.

##### `package_name`

Data type: `String`

GitHub Actions runner official package name.

You can find the package names  [here](https://github.com/actions/runner/releases)

**Example**:

```
actions-runner-linux-x64
```

##### `package_ensure`

Data type: `String`

GitHub Actions runner version to be used.

You can find latest versions [here](https://github.com/actions/runner/releases)

**Example**:

```
2.272.0
```

##### `repository_url`

Data type: `String`

A base URL to download GitHub actions runner.

**Example**:

```
https://github.com/actions/runner/releases/download
```

##### `user`

Data type: `String`

User to be used in Service and directories.

##### `group`

Data type: `String`

Group to be used in Service and directories.

## Defines

### github_actions_runner::instance

#### Parameters

##### `ensure`

Data type: `Enum`

Determine if to add or remove the resource
Default value: `undef`

##### `org_name`

Data type: `String`

actions runner github organization name.

Default value: `github_actions_runner::org_name`

##### `personal_access_token`

Data type: `String`

GitHub Personal Access Token with admin permission on the repositories or the organization.

Default value: `github_actions_runner::personal_access_token`

##### `user`

Data type: `String`

User to be used in Service and directories.

Default value: `github_actions_runner::user`

##### `group`

Data type: `String`

Group to be used in Service and directories.

Default value: `github_actions_runner::group`

##### `repo_name`

Data type: `Optional[String]`

actions runner github repository name to serve.
Default value: `undef`

##### `labels`

Data type: `Optional[Array[String]]`

A list of costum lables to add to a actions runner host.

Default value: `undef`

