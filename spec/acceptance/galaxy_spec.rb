require 'spec_helper_acceptance'

describe 'galaxy class' do
  context 'default parameters' do
    # Using puppet_apply as a helper
    it 'should work idempotently with no errors' do
      pp = <<-EOS
      class { 'galaxy': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe package('git') do
      it { should be_installed }
    end

    describe user('gxcode') do
      it { should exist }
      it { should have_home_directory '/opt/galaxy' }
    end

    describe user('galaxy') do
      it { should exist }
      it { should have_home_directory '/var/opt/galaxy' }
    end

    describe file('/opt/galaxy') do
      it { should exist }
      it { should be_directory }
      it { should be_mode 755 }
      it { should be_owned_by 'gxcode' }
      it { should be_grouped_into 'gxcode' }
    end

    describe file('/var/opt/galaxy') do
      it { should exist }
      it { should be_directory }
      it { should be_mode 755 }
      it { should be_owned_by 'galaxy' }
      it { should be_grouped_into 'galaxy' }
    end

    describe command('cd /opt/galaxy/server && git status') do
      its(:stdout) { should contain('On branch release_17.05') }
    end

    describe file('/opt/galaxy/server/lib/galaxy') do
      it { should exist }
      it { should be_directory }
      it { should be_mode 755 }
      it { should be_owned_by 'gxcode' }
      it { should be_grouped_into 'gxcode' }
    end

    describe file('/bin/pip') do
      it { should exist }
      it { should be_file }
      it { should be_mode 755 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    describe command('/bin/pip --version') do
      its(:stdout) { should contain('pip 9') }
    end

    describe file('/bin/virtualenv') do
      it { should exist }
      it { should be_file }
      it { should be_mode 755 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    describe file('/opt/galaxy/server/.venv') do
      it { should exist }
      it { should be_directory }
      it { should be_mode 755 }
      it { should be_owned_by 'gxcode' }
      it { should be_grouped_into 'gxcode' }
    end

    describe file('/opt/galaxy/server/.venv/bin/activate') do
      it { should exist }
      it { should be_file }
      it { should be_mode 644 }
      it { should be_owned_by 'gxcode' }
      it { should be_grouped_into 'gxcode' }
    end

    describe file('/opt/galaxy/server/.venv/lib/python2.7/site-packages/pysam') do
      it { should exist }
      it { should be_directory }
      it { should be_mode 755 }
      it { should be_owned_by 'gxcode' }
      it { should be_grouped_into 'gxcode' }
    end
  end
end
