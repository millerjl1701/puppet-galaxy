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
          it { is_expected.to contain_class('galaxy::install').that_comes_before('Class[galaxy::postinstall]') }
          it { is_expected.to contain_class('galaxy::postinstall').that_comes_before('Class[galaxy::config]') }
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

          it { is_expected.to contain_exec('install_pip_via_curl_to_get_latest').that_comes_before('Package[virtualenv]') }
          it { is_expected.to contain_exec('install_pip_via_curl_to_get_latest').with(
            'command' => '/bin/curl --silent --show-error --retry 5 https://bootstrap.pypa.io/get-pip.py | /bin/python',
            'creates' => '/bin/pip',
          ) }

          it { is_expected.to contain_package('virtualenv').that_comes_before('Exec[create_galaxy_virtualenv]') }
          it { is_expected.to contain_package('virtualenv').with(
            'ensure'   => 'present',
            'provider' => 'pip',
          ) }

          it { is_expected.to contain_exec('create_galaxy_virtualenv').with(
            'command' => '/bin/virtualenv -p python /opt/galaxy/server/.venv',
            'user'    => 'gxcode',
            'creates' => '/opt/galaxy/server/.venv/bin/activate',
          ) }

          it { is_expected.to contain_exec('install_galaxy_virtualenv_wheels').that_subscribes_to('Exec[create_galaxy_virtualenv]') }
          it { is_expected.to contain_exec('install_galaxy_virtualenv_wheels').with(
            'command'     => '/opt/galaxy/server/.venv/bin/pip --log /opt/galaxy/server/.venv/pip.log install --index-url https://wheels.galaxyproject.org/ -r /opt/galaxy/server/lib/galaxy/dependencies/pinned-requirements.txt',
            'refreshonly' => 'true',
            'timeout'     => '0',
            'user'        => 'gxcode',
            'cwd'         => '/opt/galaxy/server/.venv',
          ) }

          it { is_expected.to contain_file('/opt/galaxy/config').with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          ) }

          it { is_expected.to contain_file('/opt/galaxy/shed_tools').with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          ) }

          it { is_expected.to contain_file('/opt/galaxy/config/galaxy.ini').with(
            'ensure' => 'present',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0644',
          ) }

          it { is_expected.to contain_file('/var/opt/galaxy/config').with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
          ) }

          it { is_expected.to contain_file('/opt/galaxy/server/dependencies').with(
            'ensure' => 'directory',
            'owner'  => 'root',
            'group'  => 'root',
            'mode'   => '0755',
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
          it { is_expected.to contain_exec('create_galaxy_virtualenv').with_user('galaxy') }
          it { is_expected.to contain_exec('install_galaxy_virtualenv_wheels').with_user('galaxy') }
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

        context "galaxy class with galaxy_wheels_repo_url set to http://localhost/" do
          let(:params){
            {
              :galaxy_wheels_repo_url => 'http://localhost/',
            }
          }
          it { is_expected.to contain_exec('install_galaxy_virtualenv_wheels').with_command('/opt/galaxy/server/.venv/bin/pip --log /opt/galaxy/server/.venv/pip.log install --index-url http://localhost/ -r /opt/galaxy/server/lib/galaxy/dependencies/pinned-requirements.txt') }
        end

        context "galaxy class with galaxy_commit_id set to SHA 1 hash" do
          let(:params){
            {
              :galaxy_commit_id => '9dca211e2fe59eaad1f7b95c8d51608b2afa05af',
            }
          }
          it { is_expected.to contain_vcsrepo('/opt/galaxy/server').with_revision('9dca211e2fe59eaad1f7b95c8d51608b2afa05af') }
        end

        context "galaxy class with galaxy_manage_venv set to false" do
          let(:params){
            {
              :galaxy_manage_venv => false,
            }
          }
          it { is_expected.to_not contain_exec('install_pip_via_curl_to_get_latest') }
          it { is_expected.to_not contain_package('virtualenv') }
          it { is_expected.to_not contain_exec('create_galaxy_virtualenv') }
          it { is_expected.to_not contain_exec('install_galaxy_virtualenv_wheels') }
        end

        context "galaxy class with galaxy_venv_dir set to /srv/galaxy/server/.venv" do
          let(:params){
            {
              :galaxy_venv_dir => '/srv/galaxy/server/.venv',
            }
          }
          it { is_expected.to contain_exec('create_galaxy_virtualenv').with(
            'command' => '/bin/virtualenv -p python /srv/galaxy/server/.venv',
            'creates' => '/srv/galaxy/server/.venv/bin/activate',
          ) }
          it { is_expected.to contain_exec('install_galaxy_virtualenv_wheels').with(
            'command' => '/srv/galaxy/server/.venv/bin/pip --log /srv/galaxy/server/.venv/pip.log install --index-url https://wheels.galaxyproject.org/ -r /opt/galaxy/server/lib/galaxy/dependencies/pinned-requirements.txt',
            'cwd'     => '/srv/galaxy/server/.venv'
          ) }
        end

        context "galaxy class with galaxy_requirements_file set to /tmp/requirements.txt" do
          let(:params){
            {
              :galaxy_requirements_file => '/tmp/requirements.txt',
            }
          }
          it { is_expected.to contain_exec('install_galaxy_virtualenv_wheels').with(
            'command' => '/opt/galaxy/server/.venv/bin/pip --log /opt/galaxy/server/.venv/pip.log install --index-url https://wheels.galaxyproject.org/ -r /tmp/requirements.txt',
          ) }
        end

        context "galaxy class with both galaxy_manage_clone and galaxy_manage_download set to true" do
          let(:params){
            {
              :galaxy_manage_clone    => true,
              :galaxy_manage_download => true,
            }
          }
          it { expect { is_expected.to contain_package('galaxy') }.to raise_error(Puppet::Error, /Error: Both galaxy_manage_clone and galaxy_manage_download were set to true./) }
        end

        context "galaxy class with both galaxy_manage_clone and galaxy_manage_download set to false" do
          let(:params){
            {
              :galaxy_manage_clone    => false,
              :galaxy_manage_download => false,
            }
          }
          it { expect { is_expected.to contain_package('galaxy') }.to raise_error(Puppet::Error, /Error: Neither galaxy_manage_clone nor galaxy_manage_download were set to true./) }
        end
        context "galaxy class with galaxy_manage_download set to true and galaxy_manage_clone set to false" do
          let(:params){
            {
              :galaxy_manage_clone    => false,
              :galaxy_manage_download => true,
            }
          }
          it { is_expected.to_not contain_vscrepo('/opt/galaxy/server') }
          it { is_expected.to contain_exec('install_galaxy_via_download').with(
            'command' => 'rm -rf /opt/galaxy/server && mkdir /opt/galaxy/server && wget -q -O - https://github.com/galaxyproject/galaxy.git/get/release_17.05.tar.gz | tar xzf - --strip-components=1 -C /opt/galaxy/server && touch /opt/galaxy/server/release_17.05_receipt',
            'creates' => '/opt/galaxy/server/release_17.05_receipt',
            'user'    => 'gxcode',
          ) }
        end
        context "galaxy class with galaxy_manage_static_setup set to false" do
          let(:params){
            {
              :galaxy_manage_static_setup    => false,
            }
          }
          it { is_expected.to_not contain_file('/opt/galaxy/config') }
          it { is_expected.to_not contain_file('/opt/galaxy/shed_tools') }
          it { is_expected.to_not contain_file('/opt/galaxy/config.galaxy.ini') }
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
