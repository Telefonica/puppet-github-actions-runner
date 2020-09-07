# Actions runner

This module is designed to auto configure all requirements to have the GitHub Actions runner  ready to run on Debian hosts.

#### Table of Contents

1. [Description](#description)

2. [Limitations - OS compatibility, etc.](#limitations)
3. [Development - Guide for contributing to the module](#development)

## Description

This module will setup all of the file and configuration needed for GitHub Actions runner to  work on any Debian host.

## Limitations

Tested on Debian 9 stretch hosts only.
full  operating systems support as describe in `metadata.json` file.


If you don't specify repository name , make sure you `Personal Access Token` is org level admin.

## Development

This module development should be just like any other puppet modules.
