require 'spec_helper'

describe 'galaxy' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "galaxy class without any parameters" do
          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('galaxy::install').that_comes_before('Class[galaxy::config]') }
          it { is_expected.to contain_class('galaxy::config') }
          it { is_expected.to contain_class('galaxy::service').that_subscribes_to('Class[galaxy::config]') }
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
