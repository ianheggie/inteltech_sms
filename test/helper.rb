require 'rubygems'
require 'coveralls'
Coveralls.wear!

require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'test/unit'
require 'shoulda-context'

unless ENV['TEST_GEM']
  puts "test/helper: Adding ../lib to $LOAD_PATH"
  $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
end
#$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'inteltech_sms'
require 'dummy_inteltech_sms'

class Test::Unit::TestCase
end
