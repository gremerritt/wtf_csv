require_relative 'wtf_csv'
require 'csv'

output = WtfCSV.scan("test_csv.csv", {:allow_row_sep_in_quoted_fields => false, :check_col_count => true, :col_threshold => 10}, ARGV[0])
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