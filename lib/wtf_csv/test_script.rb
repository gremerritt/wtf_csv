require_relative 'wtf_csv'
require 'smarter_csv'

output = WtfCSV.scan("test_csv.csv", {}, ARGV[0])
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