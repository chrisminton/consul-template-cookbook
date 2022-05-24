require 'chefspec'
require 'chefspec/berkshelf'

RSpec.configure do |c|
  # Nice output
  c.color = true
  c.tty = true
  c.formatter = :documentation
  # log level
  c.log_level = :error
  c.platform = 'centos'
  c.version = '7.8.2003'
end
