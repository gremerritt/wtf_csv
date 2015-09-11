require_relative 'wtf_csv'
require 'smarter_csv'

output = WtfCSV.scan("1441933203831-hws.evertrue.data.csv", {:allow_row_sep_in_quoted_fields => true, :escape_char => '"',:ignore_string => 'EVERTRUE-EOF'}, ARGV[0])
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