# consul-template-cookbook

[![Build Status](https://travis-ci.org/ist-dsi/consul-template-cookbook.svg?branch=master)](https://travis-ci.org/ist-dsi/consul-template-cookbook)
[![Cookbook Version](https://img.shields.io/cookbook/v/consul-template-cookbook.svg)](https://supermarket.chef.io/cookbooks/consul-template-cookbook)

Installs and configures [consul-template](https://github.com/hashicorp/consul-template).

This is a fork of https://github.com/adamkrone/chef-consul-template with the following changes:

* Drop support for Windows
* No longer use libarchive as it causes a lot of problems.
* Use the tgz packages instead of the zip ones.
* Use a more modern style of defining resources.
* Collapse all the recipes into default.
* Only define the checksums for the latest 3 minor versions.
* Support the arm architecture.
* Only support the linux OS.

## Supported Platforms

* Ubuntu 20.04
* Debian 12.8
* Centos 7.9

## Attributes

* `node['consul_template']['base_url']` - Base URL for consul-template binary files
* `node['consul_template']['version']` - Version of consul-template to install.
  Used to determine which binary to grab from the base_url.
* `'node['consul_template']['install_dir']` - Directory where consul-template
  should be installed.
* `node['consul_template']['checksums']` - Contains a hash of checksums where
  the key is the file for a given OS/architecture, and the value is the
  associated checksum. For example, `consul-template_0.3.1_linux_amd64`.
* `node['consul_template']['config_dir']` - The directory that contains the
  configuration files for consul-template.
* `node['consul_template']['service_user']` - Defines the user that should be
  used for the consul-template service.
* `node['consul_template']['service_group']` - Defines the group that should be
  used for the consul-template service.
* `node['consul_template']['template_mode']` - File permissions mode for all
  consul-template configuration files.
* `node['consul_template']['consul_addr']` - Name:port to access consul (default: `127.0.0.1:8500`)
* `node['consul_template']['vault_addr']` - URL to access Vault (default: `https://127.0.0.1:8200`)

Additionally, the contents of the `node['consul_template']['config']` hash will be reflected into the default configuration file -- `/etc/consul-template.d/default.json`.

## Recipes

### default

Installs and configures consul-template.

## LWRP

### consul_template_config

Creates configuration files in `node['consul_template']['config_dir']`, and
reloads the configuration.

For example, if you want to generate HAProxy's config using consul-template,
you may include something like this in your recipe:

```ruby
consul_template_config 'haproxy' do
  templates [{
    source: '/etc/haproxy/haproxy.cfg.ctmpl',
    destination: '/etc/haproxy/haproxy.cfg',
    command: 'service haproxy restart'
  }]
  notifies :reload, 'service[consul-template]', :delayed
end
```
