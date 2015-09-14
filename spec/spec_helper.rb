require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)

require 'wtf_csv'

RSpec.configure do |config|
  config.expect_with :rspec do |c| 
    c.syntax = :should
  end
end