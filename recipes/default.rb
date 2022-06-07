service_group = group node['consul_template']['service_group'] do
  comment "Service group for #{name}"
  system true
  not_if { node['consul_template']['service_user'] == 'root' }
  not_if { node['consul_template']['create_service_user'] == false }
end

service_user = user node['consul_template']['service_user'] do
  comment "Service user for #{name}"
  group service_group.name
  home node['consul_template']['config_dir']
  manage_home false
  shell '/usr/sbin/nologin'
  system true
  not_if { node['consul_template']['service_user'] == 'root' }
  not_if { node['consul_template']['create_service_user'] == false }
  action [:create, :modify]
end

directory node['consul_template']['config_dir'] do
  owner service_user.name
  group service_group.name
end

# ==== Install Consul Template from binary =============================================================================
install_arch = if node['kernel']['machine'].include?('arm64')
                 'arm64'
               elsif node['kernel']['machine'].include?('arm')
                 'arm'
               elsif node['kernel']['machine'].include?('i386')
                 '386'
               else
                 'amd64'
               end
install_version = ['consul-template', node['consul_template']['version'], 'linux', install_arch].join('_')
destination_dir = ['consul-template', node['consul_template']['version']].join('_')
url = ::URI.join(node['consul_template']['base_url'], "#{node['consul_template']['version']}/", "#{install_version}.zip").to_s
install_path = "#{node['consul_template']['install_dir']}/#{destination_dir}"
archive_path = ::File.join(Chef::Config[:file_cache_path], "#{install_version}.zip")

remote_file archive_path do
  source url
  checksum node['consul_template']['checksums'][install_version]
  action :create_if_missing
end

archive_file archive_path do
  destination install_path
  mode '0755'
  owner service_user.name
  group service_group.name
end

link "#{node['consul_template']['install_dir']}/consul-template" do
  to "#{install_path}/consul-template"
  mode '0755'
end

# ==== Create Service ==================================================================================================
consul_addr = node['consul_template']['consul_addr']
consul_addr_option = consul_addr.nil? || consul_addr.empty? ? '' : " -consul-addr #{node['consul_template']['consul_addr']}"

vault_addr = node['consul_template']['vault_addr']
vault_addr_option = vault_addr.nil? || vault_addr.empty? ? '' : " -vault-addr #{node['consul_template']['vault_addr']}"

command = "#{node['consul_template']['install_dir']}/consul-template -config #{node['consul_template']['config_dir']}" \
          "#{consul_addr_option}#{vault_addr_option} -log-level #{node['consul_template']['log_level']}"
timeout_start = node['consul_template']['service_timeoutstartsec'] ? "TimeoutStartSec=#{node['consul_template']['service_timeoutstartsec']}" : ''
systemd_unit 'consul-template.service' do
  content <<-EOF
[Unit]
Description=Consul Template Daemon
Requires=network-online.target
Wants=vault.service consul.service
After=network-online.target vault.service consul.service

[Service]
Environment=#{node['consul_template']['environment_variables'].map { |key, val| %("#{key}=#{val}") }.join(' ')}
ExecStartPre=#{node['consul_template']['service_execstartpre']}
ExecStart=#{command}
ExecReload=/bin/kill -HUP $MAINPID
User=#{service_user.name}
Restart=on-failure
RestartSec=5s
#{timeout_start}

[Install]
WantedBy=multi-user.target
EOF

  action [:create, :enable]
end

service 'consul-template' do
  supports status: true, restart: true, reload: true
  action :start
end
