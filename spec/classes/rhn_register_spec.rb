require 'spec_helper'

describe 'rhn_register', :type => 'class' do
  context "On a RedHat system" do
    let :facts do {
      :osfamily => 'RedHat',
      :operatingsystem => 'RedHat'
    } end

    context "with a username and password supplied" do
      let :params do {
        :username => 'test',
        :password => 'test',
      } end

      it { should contain_exec('register_with_rhn').with(
        :command => '/usr/sbin/rhnreg_ks --username test --password test'
      ) }
    end

    context "with a server url defined" do
      let :params do {
        :username => 'test',
        :password => 'test',
        :serverurl => 'http://example.com/XMLRPC',
      } end

      it { should contain_exec('register_with_rhn').with(
        :command => '/usr/sbin/rhnreg_ks --username test --password test --serverUrl http://example.com/XMLRPC'
      ) }
    end

    context "with an sslca_source specified" do
      let :params do {
        :username     => 'test',
        :password     => 'test',
        :sslca        => '/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT',
        :sslca_source => 'puppet:///modules/local_files/satellite_ca.crt',
      } end

      it { should contain_file('rhn-ssl-ca').with(
        :source => 'puppet:///modules/local_files/satellite_ca.crt',
        :path   => '/usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT',
      ) }

      it { should contain_exec('register_with_rhn').with(
        :command => '/usr/sbin/rhnreg_ks --username test --password test --sslCACert /usr/share/rhn/RHN-ORG-TRUSTED-SSL-CERT'
      ) }
    end

    context "with an sslca_source specified but not sslca" do
      let :params do {
        :username     => 'test',
        :password     => 'test',
        :sslca_source => 'puppet:///modules/local_files/satellite_ca.crt',
      } end

      it {
        should raise_error(Puppet::Error, /sslca_source can only be used when sslca is also specified/)
      }
    end

    context "without a username/password or activation key supplied" do
      it {
        should raise_error(Puppet::Error, /Either an activation key or username\/password is required to register/)
      }
    end
  end

  context "On an Ubuntu system" do

    let :facts do {
      :osfamily        => 'Debian',
      :operatingsystem => 'Ubuntu'
    } end

    let :params do {
      :username => 'test',
      :password => 'test',
    } end

    it {
      should raise_error(Puppet::Error, /Ubuntu with RHN or Satellite using this puppet/)
    }
  end
end
