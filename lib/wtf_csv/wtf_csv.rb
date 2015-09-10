module WtfCSV
  def self.scan(file, options = {}, debug = false)
    
    default_options = {
      :col_sep => ',',
      :row_sep => "\n",
      :quote_char => '"',
      :escape_char => '"',
      :check_col_count => true,
      :num_cols => 0,
      :col_threshold => 80,
      :row_sep_in_quoted_fields => false,
      :file_encoding => 'utf-8',
    }
    options = default_options.merge(options)
    
    quote_errors = Array.new
    column_errors = Array.new
    char_errors = Array.new
    column_counts = Array.new if options[:check_col_count]
    
    line_count = 0
    
    f = file.respond_to?(:readline) ? file : File.open(file, "r:#{options[:file_encoding]}")
    
    old_row_sep = $/
    $/ = options[:row_sep]  # credit to tilo, author of smarter_csv, on how to loop over lines without reading whole file into memory
    
    while ! f.eof?
      line = f.readline
      begin
        line.chomp!
        
        # if there are any escaped quotes, throw them out
        line.gsub!("#{options[:escape_char]}#{options[:quote_char]}", '')
        
        # originally I wan't to do something like checking if the number of quote_char's in the
        # line was even/odd, then do 'if even, load the line and check the number of columns'
        # or 'if odd, must be an error so scan the line to figure out where'. However, an even
        # number of quote_char's doesn't mean the line is good - consider "valA",aa"valB"
        
        # do a pass to see if there are any quotes mid-line like: "fds",ds"f"
        is_quoted = false
        new_col = true
        quote_has_ended = false
        quote_error = false
        pos_start = 0
        col_number = 0
        
        line.each_char.with_index do |char, position|
          if debug
            puts "\nchar:            #{char}"
            puts "is_quoted:       #{is_quoted}"
            puts "new_col:         #{new_col}"
            puts "quote_has_ended: #{quote_has_ended}"
            puts "quote_error:     #{quote_error}"
            puts "pos_start:       #{pos_start}"
            puts "col_number:      #{col_number}"
          end
        
          if char != options[:quote_char] and char != options[:col_sep]
            puts " > a" if debug
            new_col = false
            if quote_has_ended
              puts " > a a" if debug
              quote_error = true
            end
          elsif char == options[:quote_char] and is_quoted
            puts " > b" if debug
            quote_has_ended = true
            is_quoted = false
          elsif char == options[:quote_char]
            puts " > c" if debug
            if new_col
              puts " > c a" if debug
              is_quoted = true
              new_col = false
            else
              puts " > c b" if debug
              quote_error = true
            end
          elsif char == options[:col_sep] and ! is_quoted
            puts " > d" if debug
            if quote_error
              puts " > d a" if debug
              quote_errors.push("#{line_count + 1},#{col_number + 1},#{line[pos_start..(position - 1)]}")
              quote_error = false
            end
            new_col = true
            quote_has_ended = false
            pos_start = position + 1
            col_number += 1
          end
        end
        
        quote_error = true if is_quoted
        
        if quote_error
          quote_errors.push("#{line_count + 1},#{col_number + 1},#{line[pos_start..line.length]}")
        end
        
        line_count += 1
        
        
        if options[:check_col_count]
          fnd = false
          column_counts.each do |val|
            if val[0] == col_number + 1
              val[1].push(line_count)
              fnd = true
              break
            end
          end
          
          if ! fnd
            column_counts.push([col_number + 1, [line_count]])
          end
        end
        
      rescue Exception => msg
        puts msg
      ensure
        $/ = old_row_sep
      end
    end
    
    if options[:check_col_count]
      column_counts.sort_by! { |val| val[1].length }
      column_counts.reverse!
    
      # if we're looking for an absolute number...
			if options[:num_cols] != 0
				column_counts.each do |val|
					if val[0] != options[:num_cols]
						val[1].each { |row| column_errors.push("#{row},#{val[0]},#{options[:num_cols]}") }
					end
				end
			
			# else we'll try to figure out the target number of columns with :col_threshold
			elsif column_counts.length > 1
			  if column_counts[0][1].length >= line_count * (options[:col_threshold].to_f / 100)
			    column_counts.drop(1).each { |val| val[1].each { |row| column_errors.push("#{row},#{val[0]},#{column_counts[0][0]}") } }
			  else
			    column_counts.each { |val| column_errors.push("#{val[0]},#{val[1].length}") }
			  end
			end
    end
    
    return {quote_errors: quote_errors,
            column_errors: column_errors,
            char_errors: char_errors}
  end
end