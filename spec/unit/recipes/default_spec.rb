require 'spec_helper'

describe 'consul-template::default' do
  context 'default' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new.converge('consul-template-cookbook::default')
    end

    # Installation
    it 'symlinks to /usr/local/bin/consul-template' do
      expect(chef_run).to create_link('/usr/local/bin/consul-template')
    end

    # Service
    it 'should create the consul-template config directory' do
      expect(chef_run).to create_directory('/etc/consul-template.d')
    end

    it 'should create the consul-template systemd unit' do
      expect(chef_run).to create_systemd_unit('consul-template.service')
    end

    it 'should start the consul-template service' do
      expect(chef_run).to start_service('consul-template')
    end

    it 'should create the consul-template service user' do
      expect(chef_run).to create_user('consul-template')
      expect(chef_run).to create_group('consul-template')
    end

    it 'should enable the consul-template service' do
      expect(chef_run).to enable_systemd_unit('consul-template.service')
    end
  end

  context 'additional settings' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new do |node, _server|
        node.override['consul_template']['service_execstartpre'] = '/usr/local/bin/wrapper.sh'
        node.override['consul_template']['vault_addr'] = 'https://my.vault.server:8200'
      end.converge('consul-template-cookbook::default')
    end

    it 'should create the consul-template systemd unit with additional settings' do
      expect(chef_run).to create_systemd_unit('consul-template.service').with_content(
        %r{ExecStartPre=/usr/local/bin/wrapper.sh}
      )
      expect(chef_run).to create_systemd_unit('consul-template.service').with_content(
        /User=consul-template/
      )
      expect(chef_run).to create_systemd_unit('consul-template.service').with_content(
        %r{ExecStart=/usr/local/bin/consul-template -config /etc/consul-template.d -consul-addr 127.0.0.1:8500 -vault-addr https://my.vault.server:8200 -log-level warn}
      )
    end
  end
end
