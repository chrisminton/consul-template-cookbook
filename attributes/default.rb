default['consul_template'] = {
  'base_url' => 'https://releases.hashicorp.com/consul-template/',
  'version' => '0.29.0',
  'install_dir' => '/usr/local/bin',

  # Service attributes
  'log_level' => 'warn',
  'config_dir' => '/etc/consul-template.d',
  'consul_addr' => '127.0.0.1:8500',
  'vault_addr' => 'https://127.0.0.1:8200',

  'environment_variables' => {},

  'create_service_user' => true,
  'service_user' => 'consul-template',
  'service_group' => 'consul-template',
  'service_execstartpre' => "",
  'template_mode' => 0600,

  # Config attributes
  'config' => {},
}
