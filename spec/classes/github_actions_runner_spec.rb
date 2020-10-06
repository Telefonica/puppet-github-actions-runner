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
          :base_dir_name         => '/tmp/actions-runner',
          :instances             => { 'first_runner' => { 'labels' => ['test_label1', 'test_label2'], 'repo_name' => 'test_repo'}},
        }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('github_actions_runner') }
      it { is_expected.to contain_class('github_actions_runner::config') }

    end
  end
end
