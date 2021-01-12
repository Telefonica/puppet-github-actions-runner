require 'spec_helper'

describe 'github_actions_runner' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          :instances  => { 'first_runner' => { 'labels' => ['test_label1', 'test_label2'], 'repo_name' => 'test_repo'}}, }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('github_actions_runner') }

      context 'is expected to create a github_actions_runner root directory' do
        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0').with({
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          })
        end
      end

      context 'is expected to create a github_actions_runner instance directory' do
        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner').with({
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          })
        end
      end

      context 'is expected to create a github_actions_runner service' do
        it do
          is_expected.to contain_service('github-actions-runner.first_runner.service').with('ensure' => 'running', 'enable' => true)
        end
      end

      context 'is expected to contain archive' do
        it do
          is_expected.to contain_archive("first_runner-actions-runner-linux-x64-2.272.0.tar.gz").with({
            'ensure' => 'present',
            'user'   => 'root',
            'group'  => 'root',
          })
        end
      end

      context 'is expected to contain an ownership exec' do
        it do
          is_expected.to contain_exec('first_runner-ownership').with({
            'user'    => 'root',
            'command' => '/bin/chown -R root:root /some_dir/actions-runner-2.272.0/first_runner',
          })
        end
      end

      context 'is expected to contain a Run exec' do
        it do
          is_expected.to contain_exec('first_runner-run_configure_install_runner.sh').with({
            'user'    => 'root',
            'command' => '/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh',
          })
        end
      end

      context 'is expected to create a github_actions_runner installation script' do
        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with({
            'ensure' => 'present',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          })
        end
      end

      context 'is expected to create a github_actions_runner installation script with config in content' do
        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with_content(/\/some_dir\/actions-runner-2.272.0\/first_runner\/config.sh/)
        end
      end

      context 'is expected to create a github_actions_runner installation script with repo url in content' do
        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with_content(/https:\/\/github.com\/github_org\/test_repo/)
        end
      end

      context 'is expected to create a github_actions_runner installation script with labels in content' do
        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/first_runner/configure_install_runner.sh').with_content(/test_label1,test_label2/)
        end
      end
    end
  end
end


describe 'github_actions_runner' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          :user       => 'test_user',
          :group      => 'group_user',
          :instances  => { 'second_runner' => { 'labels' => ['test_label1', 'test_label2'], 'repo_name' => 'test_repo'}}, }
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_class('github_actions_runner') }

      context 'is expected to create a github_actions_runner root directory with test user' do
        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0').with({
            'ensure' => 'directory',
            'owner'  => 'test_user',
            'group'  => 'group_user',
            'mode'   => '0644',
          })
        end
      end

      context 'is expected to create a github_actions_runner instance directory with test user' do
        it do
          is_expected.to contain_file('/some_dir/actions-runner-2.272.0/second_runner').with({
            'ensure' => 'directory',
            'owner'  => 'test_user',
            'group'  => 'group_user',
            'mode'   => '0644',
          })
        end
      end
    end
  end
end
