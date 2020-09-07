require 'spec_helper'

describe 'github_actions_runner' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      let(:params) do
        {
          :ensure                => 'present',
          :org_name              => 'test_org',
          :personal_access_token => 'test_PAT',
          :package_name          => 'test_package',
          :package_ensure        => '1.0.1',
          :repository_url        => 'https://test_url',
          :user                  => 'test_user',
          :group                 => 'test_group',
          :labels                => ['test_label1', 'test_label2'],
          :repo_name             => 'test_repo',
          :base_dir_name         => '/tmp/actions-runner',
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('github_actions_runner') }
      it { is_expected.to contain_class('github_actions_runner::service') }
      it { is_expected.to contain_class('github_actions_runner::install') }
      it { is_expected.to contain_class('github_actions_runner::config') }

      context 'is expected to create a github_actions_runner service' do
        it do
          is_expected.to contain_service('github-actions-runner').with('ensure' => 'running', 'enable' => true)
        end
      end

      context 'is expected to create a github_actions_runner root directory' do
        it do
          is_expected.to contain_file('/tmp/actions-runner-1.0.1').with({
            'ensure' => 'directory',
            'owner'  => 'test_user',
            'group'  => 'test_group',
            'mode'   => '0644',
          })
        end
      end

      context 'is expected to create a github_actions_runner installation script' do
        it do
          is_expected.to contain_file('/tmp/actions-runner-1.0.1/configure_install_runner.sh').with({
            'ensure' => 'present',
            'owner'  => 'test_user',
            'group'  => 'test_group',
            'mode'   => '0755',
          })
        end
      end

      context 'is expected to create a github_actions_runner installation script with content' do
        it do
          is_expected.to contain_file('/tmp/actions-runner-1.0.1/configure_install_runner.sh').with_content(/\/tmp\/actions-runner-1.0.1\/config.sh/)
        end
      end
    end
  end
end
