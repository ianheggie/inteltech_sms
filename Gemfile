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
end

group :test do
  gem "rcov", ">= 0", :platforms => :mri_18
  gem "simplecov", ">= 0", :require => false, :platforms => :ruby_19
end
