require_relative 'wtf_csv'
require 'csv'

output = WtfCSV.scan("test_csv.csv", {}, ARGV[0])
output.each do |title, err_array|
	puts title
	err_array.each do |err|
	  puts "  #{err}"
	end
end