require 'spec_helper'

describe 'github_actions_runner' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'org_name' => 'github_org',
          'instances' => {
            'first_runner' => {
              'labels' => ['test_label1', 'test_label2'],
              'repo_name' => 'test_repo',
            },
          },
        }
      end

      context 'is expected compile' do
        it do
          is_expected.to compile.with_all_deps
          is_expected.to contain_class('github_actions_runner')
        end
      end

      context 'is expected compile and raise error when required values are undefined' do
        let(:params) do
          super().merge('org_name' => :undef, 'enterprise_name' => :undef)
        end

        it do
          is_expected.to compile.and_raise_error(%r{Either 'org_name' or 'enterprise_name' is required to create runner instances})
        end
      end

      context 'is expected to create a github_actions_runner root directory' do
        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0').with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          )
        end
      end

      context 'is expected to create a github_actions_runner a new root directory' do
        let(:params) do
          super().merge('base_dir_name' => '/tmp/actions-runner')
        end

        it do
          is_expected.to contain_file('/tmp/actions-runner-2.272.0').with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          )
        end
      end

      context 'is expected to create a github_actions_runner root directory with test user' do
        let(:params) do
          super().merge('user'  => 'test_user',
                        'group' => 'test_group')
        end

        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0').with(
            'ensure' => 'directory',
            'owner'  => 'test_user',
            'group'  => 'test_group',
            'mode'   => '0644',
          )
        end
      end

      context 'is expected to create a github_actions_runner instance directory' do
        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner').with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          )
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner').that_requires(['File[/some_dir/actions-runner-2.272.0]'])
        end
      end

      context 'is expected to create a github_actions_runner instance directory with test user' do
        let(:params) do
          super().merge('user'  => 'test_user',
                        'group' => 'test_group')
        end

        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner').with(
            'ensure' => 'directory',
            'owner'  => 'test_user',
            'group'  => 'test_group',
            'mode'   => '0644',
          )
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner').that_requires(['File[/some_dir/actions-runner-2.272.0]'])
        end
      end

      context 'is expected to contain archive' do
        it do
          is_expected.to contain_archive('first_runner-actions-runner-linux-x64-2.272.0.tar.gz').with(
            'ensure' => 'present',
            'user'   => 'root',
            'group'  => 'root',
          )
          is_expected.to contain_archive('first_runner-actions-runner-linux-x64-2.272.0.tar.gz').that_requires(['File[/some_dir/actions-runner-2.272.0/first_runner]'])
        end
      end

      context 'is expected to contain archive with test package and test url' do
        let(:params) do
          super().merge('package_name'    => 'test_package',
                        'package_ensure'  => '9.9.9',
                        'repository_url'  => 'https://test_url')
        end

        it do
          is_expected.to contain_archive('first_runner-test_package-9.9.9.tar.gz').with(
            'ensure' => 'present',
            'user'   => 'root',
            'group'  => 'root',
            'source' => 'https://test_url/v9.9.9/test_package-9.9.9.tar.gz',
          )
          is_expected.to contain_archive('first_runner-test_package-9.9.9.tar.gz').that_requires(['File[/some_dir/actions-runner-9.9.9/first_runner]'])
        end
      end

      context 'is expected to contain an ownership exec' do
        it do
          is_expected.to contain_exec('first_runner-ownership').with(
            'user'    => 'root',
            'command' => '/bin/chown -R root:root /some_dir/actions-runner-2.272.0/first_runner',
          )
          is_expected.to contain_exec('first_runner-ownership').that_subscribes_to('Archive[first_runner-actions-runner-linux-x64-2.272.0.tar.gz]')
        end
      end

      context 'is expected to contain a exec checking runner configured' do
        it do
          is_expected.to contain_exec('first_runner-check-runner-configured').with(
            'user'    => 'root',
            'command' => 'true',
            'unless' => 'test -f /some_dir/actions-runner-2.272.0/first_runner/runsvc.sh',
            'path' => ['/bin', '/usr/bin'],
          )
          is_expected.to contain_exec('first_runner-check-runner-configured').that_notifies('Exec[first_runner-run_configure_install_runner.sh]')
        end
      end

      context 'is expected to contain a Run exec' do
        it do
          is_expected.to contain_exec('first_runner-run_configure_install_runner.sh').with(
            'user'    => 'root',
            'command' => '/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh',
          )
        end
      end

      context 'installation scripts for different types of runners' do
        let(:params) do
          super().merge(
            'org_name' => :undef,
            'enterprise_name' => :undef,
            'instances' => {
              'first_runner' => {
                'org_name' => 'github_org',
                'repo_name' => 'test_repo',
              },
              'org_runner' => {
                'org_name' => 'github_org',
                'labels' => ['default'],
              },
              'enterprise_runner' => {
                'org_name' => :undef,
                'enterprise_name' => 'test_enterprise',
                'labels' => ['default'],
              },
            },
          )
        end

        it 'creates a repo specific runner script' do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with(
            'ensure'  => 'present',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0755',
          )
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with_content(
            %r{https://api.github.com/repos/github_org/test_repo/actions/runners/registration-token},
          )
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with_content(%r{--url https://github.com/github_org/test_repo })
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with_content(%r{--name foo-first_runner })
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').that_requires('Archive[first_runner-actions-runner-linux-x64-2.272.0.tar.gz]')
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').that_notifies('Exec[first_runner-run_configure_install_runner.sh]')
        end

        it 'creates an org specific runner script' do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/org_runner/configure_install_runner.sh').with(
            'ensure'  => 'present',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0755',
          )
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/org_runner/configure_install_runner.sh').with_content(
            %r{https://api.github.com/orgs/github_org/actions/runners/registration-token},
          )
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/org_runner/configure_install_runner.sh').with_content(%r{--url https://github.com/github_org })
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/org_runner/configure_install_runner.sh').with_content(%r{--name foo-org_runner })
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/org_runner/configure_install_runner.sh').that_requires('Archive[org_runner-actions-runner-linux-x64-2.272.0.tar.gz]')
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/org_runner/configure_install_runner.sh').that_notifies('Exec[org_runner-run_configure_install_runner.sh]')
        end

        it 'creates an enterprise specific runner script' do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/enterprise_runner/configure_install_runner.sh').with(
            'ensure'  => 'present',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0755',
          )
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/enterprise_runner/configure_install_runner.sh').with_content(
            %r{https://api.github.com/enterprises/test_enterprise/actions/runners/registration-token},
          )
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/enterprise_runner/configure_install_runner.sh').with_content(%r{--url https://github.com/enterprises/test_enterprise   })
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/enterprise_runner/configure_install_runner.sh').with_content(%r{--name foo-enterprise_runner })
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/enterprise_runner/configure_install_runner.sh').that_requires(
            'Archive[enterprise_runner-actions-runner-linux-x64-2.272.0.tar.gz]',
          )
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/enterprise_runner/configure_install_runner.sh').that_notifies('Exec[enterprise_runner-run_configure_install_runner.sh]')
        end
      end

      context 'is expected to create a github_actions_runner installation script with test version' do
        let(:params) do
          super().merge('package_ensure' => '9.9.9')
        end

        it do
          is_expected.to contain_file('/some_dir/actions-runner-9.9.9/first_runner/configure_install_runner.sh').with(
            'ensure' => 'present',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          )
          is_expected.to contain_file('/some_dir/actions-runner-9.9.9/first_runner/configure_install_runner.sh').that_requires('Archive[first_runner-actions-runner-linux-x64-9.9.9.tar.gz]')
          is_expected.to contain_file('/some_dir/actions-runner-9.9.9/first_runner/configure_install_runner.sh').that_notifies('Exec[first_runner-run_configure_install_runner.sh]')
        end
      end

      context 'is expected to create a github_actions_runner installation script with config in content' do
        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with_content(%r{/some_dir/actions-runner-2.272.0/first_runner/config.sh})
        end
      end

      context 'is expected to create a github_actions_runner installation script with github org in content' do
        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with_content(%r{https://github.com/github_org/test_repo})
        end
      end

      context 'is expected to create a github_actions_runner installation script with test_org in content ignoring enterprise_name' do
        let(:params) do
          super().merge('org_name' => 'test_org', 'enterprise_name' => 'test_enterprise')
        end

        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with_content(%r{https://github.com/test_org/test_repo})
        end
      end

      context 'is expected to create a github_actions_runner installation script with test_org in content' do
        let(:params) do
          super().merge('org_name' => 'test_org')
        end

        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with_content(%r{https://github.com/test_org/test_repo})
        end
      end

      context 'is expected to create a github_actions_runner installation script with test_enterprise in content' do
        let(:params) do
          super().merge('org_name'        => :undef,
                        'enterprise_name' => 'test_enterprise')
        end

        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with_content(%r{https://github.com/enterprises/test_enterprise})
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with_content(%r{--url https://github.com/enterprises/test_enterprise })
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with_content(%r{--name foo-first_runner })
        end
      end

      context 'is expected to create a github_actions_runner installation script with labels in content' do
        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with_content(%r{test_label1,test_label2})
        end
      end

      context 'is expected to create a github_actions_runner installation script with PAT in content' do
        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with_content(%r{authorization: token PAT})
        end
      end

      context 'is expected to create a github_actions_runner installation script with test_PAT in content' do
        let(:params) do
          super().merge('personal_access_token' => 'test_PAT')
        end

        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with_content(%r{authorization: token test_PAT})
        end
      end

      context 'is expected to create a github_actions_runner with service active and enabled' do
        let(:params) do
          super().merge(
            'http_proxy' => 'http://proxy.local',
            'https_proxy' => 'http://proxy.local',
            'no_proxy' => 'example.com',
            'instances' => {
              'first_runner' => {
                'labels' => ['test_label1'],
                'repo_name' => 'test_repo',
              },
            },
          )
        end

        it do
          is_expected.to contain_systemd__unit_file('github-actions-runner.first_runner.service').with(
            'ensure' => 'present',
            'enable' => true,
            'active' => true,
          )
          is_expected.to contain_systemd__unit_file('github-actions-runner.first_runner.service').that_requires(['File[/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh]',
                                                                                                                 'File[/some_dir/actions-runner-2.272.0/first_runner/.path]',
                                                                                                                 'Exec[first_runner-run_configure_install_runner.sh]'])
        end
      end

      context 'is expected to create a .path file with a specific requires and notifies' do
        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/.path')
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/.path').that_requires(['Archive[first_runner-actions-runner-linux-x64-2.272.0.tar.gz]',
                                                                                                            'Exec[first_runner-run_configure_install_runner.sh]'])
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/.path').that_notifies('Systemd::Unit_file[github-actions-runner.first_runner.service]')
        end
      end

      context 'is expected to create a .path file in an instance with default path list' do
        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/.path').with(
            'ensure'  => 'present',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'content' => nil,
          )
        end
      end

      context 'is expected to create a .path file in an instance, setting path at global level' do
        let(:params) do
          super().merge(
            'path' => [
              '/usr/bin',
              '/bin',
            ],
          )
        end

        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/.path').with(
            'ensure'  => 'present',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'content' => "/usr/bin:/bin\n",
          )
        end
      end

      context 'is expected to create a .path file in an instance, setting the path at instance level' do
        let(:params) do
          super().merge(
            'path' => [
              '/usr/bin',
              '/bin',
            ],
            'instances' => {
              'first_runner' => {
                'path' => [
                  '/bin',
                  '/other/path',
                ]
              },
            },
          )
        end

        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/.path').with(
            'ensure'  => 'present',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'content' => "/bin:/other/path\n",
          )
        end
      end

      # .env
      context 'is expected to create a .env file with a specific requires and notifies' do
        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/.env')
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/.env').that_requires(['Archive[first_runner-actions-runner-linux-x64-2.272.0.tar.gz]',
                                                                                                           'Exec[first_runner-run_configure_install_runner.sh]'])
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/.env').that_notifies('Systemd::Unit_file[github-actions-runner.first_runner.service]')
        end
      end

      context 'is expected to create a .env file in an instance with default env hash (nil content)' do
        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/.env').with(
            'ensure'  => 'present',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'content' => nil,
          )
        end
      end

      context 'is expected to create a .env file in an instance, setting env at global level' do
        let(:params) do
          super().merge(
            'env' => {
              'foo' => 'bar',
              'key' => 'value',
            },
          )
        end

        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/.env').with(
            'ensure'  => 'present',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'content' => "foo=bar\nkey=value\n",
          )
        end
      end

      context 'is expected to create a .env file in an instance, setting the env at instance level' do
        let(:params) do
          super().merge(
            'env' => {
              'foo' => 'bar',
              'key' => 'value',
            },
            'instances' => {
              'first_runner' => {
                'env' => {
                  'other' => 'value',
                }
              },
            },
          )
        end

        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/.env').with(
            'ensure'  => 'present',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
            'content' => "other=value\n",
          )
        end
      end

      context 'is expected to remove github_actions_runner unit_file and other resources' do
        let(:params) do
          super().merge(
            'http_proxy' => 'http://proxy.local',
            'https_proxy' => 'http://proxy.local',
            'no_proxy' => 'example.com',
            'instances' => {
              'first_runner' => {
                'ensure' => 'absent',
                'labels' => ['test_label1'],
                'repo_name' => 'test_repo',
              },
            },
          )
        end

        it do
          is_expected.to contain_systemd__unit_file('github-actions-runner.first_runner.service').with(
            'ensure' => 'absent',
            'enable' => false,
            'active' => false,
          )
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner').with(
            'ensure' => 'absent',
          )
          is_expected.to contain_archive('first_runner-actions-runner-linux-x64-2.272.0.tar.gz').with(
            'ensure' => 'absent',
          )
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with(
            'ensure' => 'absent',
          )

          is_expected.not_to contain_exec('first_runner-check-runner-configured')
          is_expected.to contain_exec('first_runner-ownership')
          is_expected.to contain_exec('first_runner-run_configure_install_runner.sh')
        end
      end

      context 'is expected to create a github_actions_runner installation with proxy settings in systemd globally in init.pp' do
        let(:params) do
          super().merge(
            'http_proxy' => 'http://proxy.local',
            'https_proxy' => 'http://proxy.local',
            'no_proxy' => 'example.com',
            'instances' => {
              'first_runner' => {
                'labels' => ['test_label1'],
                'repo_name' => 'test_repo',
              },
            },
          )
        end

        it do
          is_expected.to contain_systemd__unit_file('github-actions-runner.first_runner.service').with_content(%r{Environment="http_proxy=http://proxy.local"})
          is_expected.to contain_systemd__unit_file('github-actions-runner.first_runner.service').with_content(%r{Environment="https_proxy=http://proxy.local"})
          is_expected.to contain_systemd__unit_file('github-actions-runner.first_runner.service').with_content(%r{Environment="no_proxy=example.com"})
        end
      end

      context 'is expected to create a github_actions_runner installation with proxy settings in systemd globally in init.pp overwriting in a instance' do
        let(:params) do
          super().merge(
            'http_proxy' => 'http://proxy.local',
            'https_proxy' => 'http://proxy.local',
            'no_proxy' => 'example.com',
            'instances' => {
              'first_runner' => {
                'labels' => ['test_label1'],
                'repo_name' => 'test_repo',
                'http_proxy' => 'http://newproxy.local',
              },
            },
          )
        end

        it do
          is_expected.to contain_systemd__unit_file('github-actions-runner.first_runner.service').with_content(%r{Environment="http_proxy=http://newproxy.local"})
          is_expected.to contain_systemd__unit_file('github-actions-runner.first_runner.service').with_content(%r{Environment="https_proxy=http://proxy.local"})
          is_expected.to contain_systemd__unit_file('github-actions-runner.first_runner.service').with_content(%r{Environment="no_proxy=example.com"})
        end
      end

      context 'is expected to create a github_actions_runner installation with proxy settings in systemd' do
        let(:params) do
          super().merge(
            'instances' => {
              'first_runner' => {
                'labels' => ['test_label1'],
                'repo_name' => 'test_repo',
                'http_proxy' => 'http://proxy.local',
                'https_proxy' => 'http://proxy.local',
                'no_proxy' => 'example.com',
              },
            },
          )
        end

        it do
          is_expected.to contain_systemd__unit_file('github-actions-runner.first_runner.service').with_content(%r{Environment="http_proxy=http://proxy.local"})
          is_expected.to contain_systemd__unit_file('github-actions-runner.first_runner.service').with_content(%r{Environment="https_proxy=http://proxy.local"})
          is_expected.to contain_systemd__unit_file('github-actions-runner.first_runner.service').with_content(%r{Environment="no_proxy=example.com"})
        end
      end

      context 'is expected to create a github_actions_runner installation without proxy settings in systemd' do
        let(:params) do
          super().merge(
            'instances' => {
              'first_runner' => {
                'labels' => ['test_label1'],
                'repo_name' => 'test_repo',
              },
            },
          )
        end

        it do
          is_expected.to contain_systemd__unit_file('github-actions-runner.first_runner.service').without_content(%r{Environment="http_proxy=http://proxy.local"})
          is_expected.to contain_systemd__unit_file('github-actions-runner.first_runner.service').without_content(%r{Environment="https_proxy=http://proxy.local"})
          is_expected.to contain_systemd__unit_file('github-actions-runner.first_runner.service').without_content(%r{Environment="no_proxy=example.com"})
        end
      end

      context 'is expected to create a github_actions_runner installation with another URLs for domain and API' do
        let(:params) do
          super().merge(
            'github_domain' => 'https://git.example.com',
            'github_api' => 'https://git.example.com/api/v3',
            'instances' => {
              'first_runner' => {
                'labels' => ['test_label1'],
                'repo_name' => 'test_repo',
              },
            },
          )
        end

        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with_content(%r{--url https://git.example.com})
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with_content(%r{https://git.example.com/api/v3.* \| jq -r .token})
        end
      end

      context 'is expected to create a github_actions_runner installation with another URLs for domain and API per instance' do
        let(:params) do
          super().merge(
            'instances' => {
              'first_runner' => {
                'labels' => ['test_label1'],
                'repo_name' => 'test_repo',
              },
              'second_runner' => {
                'labels' => ['test_label1'],
                'repo_name' => 'test_repo',
                'github_domain' => 'https://git.example.foo',
                'github_api' => 'https://git.example.foo/api/v2',
              },
            },
          )
        end

        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with_content(%r{--url https://github.com})
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with_content(%r{https://api.github.com/.* \| jq -r .token})
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/second_runner/configure_install_runner.sh').with_content(%r{--url https://git.example.foo})
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/second_runner/configure_install_runner.sh').with_content(%r{https://git.example.foo/api/v2/.* \| jq -r .token})
        end
      end
    end
  end
end
