# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "inteltech_sms"
  gem.homepage = "http://github.com/ianheggie/inteltech_sms"
  gem.license = "MIT"
  gem.summary = %Q{Ruby Gem to send SMS via inteltech.com.au}
  gem.description = %Q{Ruby gem that provides an InteltechSms class to check credit and send SMS text messages to single or multiple recipients}
  gem.email = "ian@heggie.biz"
  gem.authors = ["Ian Heggie"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
    test.rcov_opts << '--exclude "gems/*"'
  end
rescue LoadError
  puts "rcov (or a dependency) is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
end

task :default => :test

begin
  require 'rdoc/task'
  Rake::RDocTask.new do |rdoc|
    version = File.exist?('VERSION') ? File.read('VERSION') : ""

    rdoc.rdoc_dir = 'rdoc'
    rdoc.title = "inteltech_sms #{version}"
    rdoc.rdoc_files.include('README*')
    rdoc.rdoc_files.include('lib/**/*.rb')
  end
rescue LoadError
  puts "rdoc (or a dependency) not available. Install it with: gem install rdoc"
end

# vi: sw=2 sm ai:
