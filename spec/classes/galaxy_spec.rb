require 'spec_helper'

describe 'galaxy' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "galaxy class without any parameters passed" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('galaxy') }
          it { is_expected.to contain_class('galaxy::preinstall').that_comes_before('Class[galaxy::install]') }
          it { is_expected.to contain_class('galaxy::install').that_comes_before('Class[galaxy::config]') }
          it { is_expected.to contain_class('galaxy::config') }
          it { is_expected.to contain_class('galaxy::service').that_subscribes_to('Class[galaxy::config]') }

          it { is_expected.to contain_user('gxcode').with(
            'ensure'     => 'present',
            'comment'    => 'Galaxy Code',
            'home'       => '/opt/galaxy',
            'managehome' => 'false',
            'system'     => 'true',
          ) }

          it { is_expected.to contain_file('/opt/galaxy').with(
            'ensure'  => 'directory',
            'owner'   => 'gxcode',
            'group'   => 'gxcode',
            'mode'    => '0755',
            'require' => 'User[gxcode]',
          ) }

          it { is_expected.to contain_user('galaxy').with(
            'ensure'     => 'present',
            'comment'    => 'Galaxy Server',
            'home'       => '/var/opt/galaxy',
            'managehome' => 'false',
            'system'     => 'true',
          ) }

          it { is_expected.to contain_file('/var/opt/galaxy').with(
            'ensure'  => 'directory',
            'owner'   => 'galaxy',
            'group'   => 'galaxy',
            'mode'    => '0755',
            'require' => 'User[galaxy]',
          ) }

          it { is_expected.to contain_package('git').with_ensure('present') }

          it { is_expected.to contain_vcsrepo('/opt/galaxy/server').with(
            'ensure'     => 'present',
            'provider'   => 'git',
            'source'     => 'https://github.com/galaxyproject/galaxy.git',
            'revision'   => 'release_17.05',
            'user'       => 'gxcode',
            'submodules' => 'false',
          ) }
        end

        context "galaxy class with galaxy_manage_git set to false" do
          let(:params){
            {
              :galaxy_manage_git => false,
            }
          }
          it { is_expected.to_not contain_package('git') }
        end

        context "galaxy class with galaxy_use_separate_users set to false" do
          let(:params){
            {
              :galaxy_use_separate_users => false,
            }
          }
          it { is_expected.to contain_user('galaxy').with(
            'ensure'     => 'present',
            'comment'    => 'Galaxy Server',
            'home'       => '/opt/galaxy',
            'managehome' => 'false',
            'system'     => 'true',
          ) }
          it { is_expected.to_not contain_user('gxcode') }
          it { is_expected.to contain_file('/opt/galaxy').with(
            'ensure'  => 'directory',
            'owner'   => 'galaxy',
            'group'   => 'galaxy',
            'mode'    => '0755',
            'require' => 'User[galaxy]',
          ) }
          it { is_expected.to contain_file('/var/opt/galaxy').with(
            'ensure'  => 'directory',
            'owner'   => 'galaxy',
            'group'   => 'galaxy',
            'mode'    => '0755',
            'require' => 'User[galaxy]',
          ) }
          it { is_expected.to contain_vcsrepo('/opt/galaxy/server').with_user('galaxy') }
        end

        context "galaxy class with galaxy_base_dir set to /srv/galaxy" do
          let(:params){
            {
              :galaxy_base_dir => '/srv/galaxy',
            }
          }
          it { is_expected.to contain_user('gxcode').with_home('/srv/galaxy') }
          it { is_expected.to contain_file('/srv/galaxy').with(
            'ensure'  => 'directory',
            'owner'   => 'gxcode',
            'group'   => 'gxcode',
            'mode'    => '0755',
            'require' => 'User[gxcode]',
          ) }
        end

        context "galaxy class with galaxy_runtime_dir set to /usr/local/var/galaxy" do
          let(:params){
            {
              :galaxy_runtime_dir => '/usr/local/var/galaxy',
            }
          }
          it { is_expected.to contain_user('galaxy').with_home('/usr/local/var/galaxy') }
          it { is_expected.to contain_file('/usr/local/var/galaxy').with(
            'ensure'  => 'directory',
            'owner'   => 'galaxy',
            'group'   => 'galaxy',
            'mode'    => '0755',
            'require' => 'User[galaxy]',
          ) }
        end

        context "galaxy class with galaxy_server_dir set to /usr/local/galaxy/server" do
          let(:params){
            {
              :galaxy_server_dir => '/usr/local/galaxy/server',
            }
          }
          it { is_expected.to contain_vcsrepo('/usr/local/galaxy/server') }
        end

        context "galaxy class with galaxy_repo_url set to http://localhost/galaxy.git" do
          let(:params){
            {
              :galaxy_repo_url => 'http://localhost/galaxy.git',
            }
          }
          it { is_expected.to contain_vcsrepo('/opt/galaxy/server').with_source('http://localhost/galaxy.git') }
        end

        context "galaxy class with galaxy_commit_id set to SHA 1 hash" do
          let(:params){
            {
              :galaxy_commit_id => '9dca211e2fe59eaad1f7b95c8d51608b2afa05af',
            }
          }
          it { is_expected.to contain_vcsrepo('/opt/galaxy/server').with_revision('9dca211e2fe59eaad1f7b95c8d51608b2afa05af') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'galaxy class without any parameters on Solaris/Nexenta' do
      let(:facts) do
        {
          :osfamily        => 'Solaris',
          :operatingsystem => 'Nexenta',
        }
      end

      it { expect { is_expected.to contain_package('galaxy') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
