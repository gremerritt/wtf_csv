require_relative 'wtf_csv'
require 'csv'

output = WtfCSV.scan("test_csv.csv", {}, ARGV[0])
puts ""
output.each do |title, err_array|
	puts title
	if err_array.length == 0
	  puts "  none"
	  next
	end
	
	err_array.each do |err|
	  puts "  #{err}"
	end
end