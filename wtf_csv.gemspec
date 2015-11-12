# -*- encoding: utf-8 -*-
require File.expand_path('../lib/wtf_csv/version', __FILE__)

Gem::Specification.new do |s|
  s.name          = 'wtf_csv'
  s.version       = WtfCSV::VERSION
  s.date          = '2015-09-11'
  s.summary       = %q{Ruby gem to detect formatting issues in a CSV}
  s.description   = %q{Ruby gem to detect formatting issues in a CSV. Can find quoting issues, incorrect column counts, and can properly handle quote-escaped line endings.}
  s.authors       = ["Greg Merritt"]
  s.email         = ["greg@evertrue.com"]
  s.homepage      = 'https://github.com/gremerritt/wtf_csv'
  s.files         = `git ls-files`.split($\)
  s.require_paths = ["lib"]
  s.licenses      = ['MIT']
  
  s.add_development_dependency 'rspec'
end