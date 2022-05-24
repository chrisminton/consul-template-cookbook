require 'spec_helper'

describe 'consul_template_config resource' do
  let(:chef_run) do
    ChefSpec::SoloRunner.new(step_into: ['consul_template_config'])
                        .converge('test::default')
  end

  describe 'create' do
    it 'should create the consul_template_config' do
      expect(chef_run).to create_consul_template_config('test')
    end

    it 'should create the config file' do
      expect(chef_run).to create_template('/etc/consul-template.d/test')
    end

    it 'should create the ctmplfile' do
      expect(chef_run).to create_template('/tmp/test.config.ctmpl')
    end

    it 'should add the test key/value' do
      expect(chef_run).to run_execute('add test key/value')
    end

    it 'should notify consul-template to restart' do
      consul_template = chef_run.consul_template_config('test')
      expect(consul_template).to notify('service[consul-template]').to(:restart).delayed
    end
  end
end
