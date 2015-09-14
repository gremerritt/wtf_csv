require_relative 'wtf_csv'
require 'smarter_csv'

output = WtfCSV.scan("1442250514842-tufts_sample_v2.csv", {:max_chars_in_field => 1000, :allow_row_sep_in_quoted_fields => true, :escape_char => '"',:ignore_string => 'EVERTRUE-EOF'}, ARGV[0]) { |p| puts "%#{p}"}
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