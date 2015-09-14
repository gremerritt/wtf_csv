require 'spec_helper'

fixture_path = 'spec/fixtures'

describe 'process files with \n line endings' do
  it 'should process a file with \n line endings' do
    options = {:row_sep => "\n"}
    output = WtfCSV.scan("#{fixture_path}/test.csv", options)
    output[:quote_errors].length.should be == 0
  end
end