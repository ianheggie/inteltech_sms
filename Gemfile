source "http://rubygems.org"
# Add dependencies required to use your gem here.
# Example:
#   gem "activesupport", ">= 2.3.5"

# Add dependencies to develop your gem here.
# Include everything needed to run rake, tests, features, etc.
group :development do
  gem "rdoc", ">= 3.12"
  gem "bundler", ">= 1.2.3"
  gem "jeweler", ">= 1.8.4"
  gem "travis", ">= 0"
  gem "travis-lint", ">= 0"
  gem 'shoulda-context', '>= 0'
  gem 'coveralls', :require => false

  if RUBY_VERSION =~ /^1.8/
    gem 'nokogiri', '~> 1.5.11' # dependency of jeweler, later versions require ruby 1.9.1
    # mime-types 2.0 requires Ruby version >= 1.9.2
    gem "mime-types", "< 2.0"
  end
end

group :test do
  gem "rcov", ">= 0", :platforms => :mri_18
  gem "simplecov", ">= 0", :require => false, :platforms => :ruby_19
end
