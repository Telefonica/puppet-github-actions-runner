require 'spec_helper'

describe 'github_actions_runner::instance',:type => :define do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'first_runner' }
      let(:instance_directory) do
        "/tmp/actions-runner-1.0.1/#{title}" 
      end
      
      let(:pre_condition) { 'include github_actions_runner' }
      let(:params) do
        {
          :ensure                => 'present',
          :org_name              => 'test_instance_org',
          :personal_access_token => 'test_instance_PAT',
          :user                  => 'test_instance_user',
          :group                 => 'test_instance_group',
          :labels                => ['test_label1', 'test_label2'],
          :repo_name             => 'test_repo',
        }
      end
      context 'is expected to create a github_actions_runner service' do
        it do
          is_expected.to contain_service('github-actions-runner-first_runner').with('ensure' => 'running', 'enable' => true)
        end
      end

      context 'is expected to create a github_actions_runner instance directory' do
        it do
          is_expected.to contain_file(instance_directory).with({
            'ensure' => 'directory',
            'owner'  => 'test_instance_user',
            'group'  => 'test_instance_group',
            'mode'   => '0644',
          })
        end
      end

      context 'is expected to create a github_actions_runner installation script' do
        it do
          is_expected.to contain_file('/tmp/actions-runner-1.0.1/first_runner/configure_install_runner.sh').with({
            'ensure' => 'present',
            'owner'  => 'test_instance_user',
            'group'  => 'test_instance_group',
            'mode'   => '0755',
          })
        end
      end

      context 'is expected to create a github_actions_runner installation script with config in content' do
        it do
          is_expected.to contain_file('/tmp/actions-runner-1.0.1/first_runner/configure_install_runner.sh').with_content(/\/tmp\/actions-runner-1.0.1\/first_runner\/config.sh/)
        end
      end

      context 'is expected to create a github_actions_runner installation script with repo url in content' do
        it do
          is_expected.to contain_file('/tmp/actions-runner-1.0.1/first_runner/configure_install_runner.sh').with_content(/https:\/\/github.com\/test_org\/test_repo/)
        end
      end

      context 'is expected to create a github_actions_runner installation script with labels in content' do
        it do
          is_expected.to contain_file('/tmp/actions-runner-1.0.1/first_runner/configure_install_runner.sh').with_content(/test_label1,test_label2/)
        end
      end
    end
  end
end
