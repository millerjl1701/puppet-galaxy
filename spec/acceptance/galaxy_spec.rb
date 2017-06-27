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
  end
end
