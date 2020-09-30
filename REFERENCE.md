# Reference

## Table of Contents

**Classes**

* [`github_actions_runner`](#github_actions_runner)
* [`github_actions_runner::install`](#github_actions_runner_install)
* [`github_actions_runner::config`](#github_actions_runner_config)
* [`github_actions_runner::service`](#github_actions_runner_service)

## Classes

### github_actions_runner

Guides the basic setup and installation of GitHub actions runnner on your system.

#### Parameters

The following parameters are available in the `apache` class.

##### `ensure`

Data type: `Enum['present', 'absent']]`
Enum, Determine if to add or remove the resource.

##### `base_dir_name`

Data type: `Absolutepath`
Location of the base directory for actions runner to be installed.

##### `repo_name`

Data type: `Optional[String]`

actions runner github repository name to serve.
Default value: `undef`

##### `org_name`

Data type: `String`

actions runner github organization name.

##### `labels`

Data type: `Optional[Array[String]]`

A list of costum lables to add to a actions runner host.

Default value: `undef`

##### `hostname`

Data type: `String`

actions runner name

Default value: $::facts['hostname']

##### `personal_access_token`

Data type: `String`

GitHub PAT with admin permission on the repositories or the origanization.


##### `package_name`

Data type: `String`

GitHub Actions runner offical package name.

**Example**:

```
actions-runner-linux-x64
```

##### `package_ensure`

Data type: `String`

GitHub Actions runner version to be used.

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

### github_actions_runner::install

Install the files and packages for the module.

### github_actions_runner::config

Main path configuration of the module installation.

### github_actions_runner::service

The service setup for this module.
