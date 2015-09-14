module WtfCSV
  def WtfCSV.scan(file, options = {}, debug = false, &block)
    
    default_options = {
      :col_sep => ',',
      :row_sep => $/,
      :quote_char => '"',
      :escape_char => '\\',
      :check_col_count => true,
      :col_threshold => 80,
      :num_cols => 0,
      :ignore_string => nil,
      :allow_row_sep_in_quoted_fields => false,
      :max_chars_in_field => nil,
      :file_encoding => 'utf-8',
    }
    options = default_options.merge(options)
    
    f = File.open(file, "r:#{options[:file_encoding]}")
    trgt_line_count = `wc -l "#{file}"`.strip.split(' ')[0].to_i
    
    if options[:row_sep] == :auto
      options[:row_sep] = SmarterCSV.guess_line_ending(f, options)
      f.rewind
    end
    
    # credit to tilo, author of smarter_csv, on how to loop over lines without reading whole file into memory
    old_row_sep = $/
    $/ = options[:row_sep]
    
    quote_errors = Array.new
    encoding_errors = Array.new
    if options[:check_col_count]
      column_errors = Array.new
      column_counts = Array.new
    end
    if ! options[:max_chars_in_field].nil?
      length_errors = Array.new
    end
    
    line_number = 0
    col_number = 0
    percent_done = 0
    previous_line = ""
    last_line_ended_quoted = false if options[:allow_row_sep_in_quoted_fields]
    field_length = 0 if ! options[:max_chars_in_field].nil?
    
    begin
      while ! f.eof?
        line = f.readline
        begin
          if ((line_number.to_f / trgt_line_count)*100).to_i > percent_done
            percent_done = ((line_number.to_f / trgt_line_count)*100).to_i
            yield percent_done
          end
        
          line.chomp!
          
          next if ! options[:ignore_string].nil? and line == options[:ignore_string]
          
          if options[:allow_row_sep_in_quoted_fields] and last_line_ended_quoted
            line_number -= 1
            last_line_ended_quoted = false
            field_length += options[:row_sep].length
          else
            is_quoted = false
            new_col = true
            quote_has_ended = false
            quote_error = false
            escape_char = false
            col_number = 0
          end
          pos_start = 0
          
          line.each_char.with_index do |char, position|
            begin
              char.ord  # this is here to check encoding. if the encoding is bad this will throw an exception
              
              if debug and line_number == 0
                puts "\n#{char}"
                puts "is_quoted: #{is_quoted}"
                puts "new_col: #{new_col}"
                puts "quote_has_ended: #{quote_has_ended}"
                puts "quote_error: #{quote_error}"
                puts "escape_char: #{escape_char}"
              end
              
              field_length += 1 if ! options[:max_chars_in_field].nil?
              
              if escape_char and options[:escape_char] == options[:quote_char] and char != options[:quote_char]
                puts " > a" if debug and line_number == 0
                escape_char = false
                is_quoted = ! is_quoted
                if ! is_quoted
                  puts " > a a" if debug and line_number == 0
                  quote_has_ended = true
                elsif ! new_col
                  puts " > a b" if debug and line_number == 0
                  quote_error = true
                  is_quoted = false
                end
              end
              
              if char != options[:quote_char] and char != options[:col_sep] and char != options[:escape_char] ## escape_char part
                puts " > b" if debug and line_number == 0
                new_col = false
                if quote_has_ended
                  puts " > b a" if debug and line_number == 0
                  quote_error = true
                end
              
              elsif char == options[:quote_char] and escape_char
                puts " > c" if debug and line_number == 0
                escape_char = false
              
              elsif char == options[:escape_char]
                puts " > d" if debug and line_number == 0
                escape_char = true
                
              elsif char == options[:quote_char] and is_quoted
                puts " > e" if debug and line_number == 0
                quote_has_ended = true
                is_quoted = false
              elsif char == options[:quote_char]
                puts " > f" if debug and line_number == 0
                if new_col
                  puts " > f a" if debug and line_number == 0
                  is_quoted = true
                  new_col = false
                else
                  puts " > f b" if debug and line_number == 0
                  quote_error = true
                end
              elsif char == options[:col_sep] and ! is_quoted
                puts " > g" if debug and line_number == 0
                if quote_error
                  puts " > g a" if debug and line_number == 0
                  quote_errors.push([line_number + 1,col_number + 1,"#{previous_line}#{line[pos_start..(position - 1)]}"])
                  quote_error = false
                end
                if ! options[:max_chars_in_field].nil?
                  puts " > g b" if debug and line_number == 0
                  length_errors.push([line_number + 1,col_number + 1]) if (field_length - 1) > options[:max_chars_in_field]
                  field_length = 0
                end
                new_col = true
                quote_has_ended = false
                previous_line = ""
                pos_start = position + 1
                col_number += 1
              end
            rescue Exception => e
              if e.message == 'invalid byte sequence in UTF-8'
                encoding_errors.push([line_number + 1,col_number + 1])
              end
            end
          end
          
          if escape_char and options[:escape_char] == options[:quote_char]
            if ! new_col and ! is_quoted
              quote_error = true
            else
              is_quoted = ! is_quoted
            end
          end
          
          if is_quoted
            if options[:allow_row_sep_in_quoted_fields]
              last_line_ended_quoted = true
              previous_line = "#{previous_line}#{line[pos_start...line.length]}#{options[:row_sep]}"
              next
            else
              quote_error = true
            end
          end
          
          quote_errors.push([line_number + 1,col_number + 1,line[pos_start..line.length]]) if quote_error
          
          if ! options[:max_chars_in_field].nil?
            length_errors.push([line_number + 1,col_number + 1]) if field_length > options[:max_chars_in_field]
            field_length = 0
          end
          
          if options[:check_col_count]
            fnd = false
            column_counts.each do |val|
              if val[0] == col_number + 1
                val[1].push(line_number)
                fnd = true
                break
              end
            end
            
            if ! fnd
              column_counts.push([col_number + 1, [line_number + 1]])
            end
          end
          
        rescue Exception => e
          # do nothing
        ensure
          line_number += 1
        end
      end
    ensure
      $/ = old_row_sep
    end
    
    if options[:check_col_count]
      column_counts.sort_by! { |val| val[1].length }
      column_counts.reverse!
      
      # if we're looking for an absolute number...
      if options[:num_cols] != 0
        column_counts.each do |val|
          if val[0] != options[:num_cols]
            val[1].each { |row| column_errors.push([row,val[0],options[:num_cols]]) }
          end
        end
      
      # else we'll try to figure out the target number of columns with :col_threshold
      elsif column_counts.length > 1
        if column_counts[0][1].length >= line_number * (options[:col_threshold].to_f / 100)
          column_counts.drop(1).each { |val| val[1].each { |row| column_errors.push([row,val[0],column_counts[0][0]]) } }
        else
          column_counts.each { |val| column_errors.push([val[0],val[1].length]) }
        end
      end
    end
    
    if ! options[:max_chars_in_field].nil? and options[:check_col_count]
      return {quote_errors: quote_errors,
              encoding_errors: encoding_errors,
              column_errors: column_errors,
              length_errors: length_errors}
    elsif ! options[:max_chars_in_field].nil?
      return {quote_errors: quote_errors,
              encoding_errors: encoding_errors,
              length_errors: length_errors}
    elsif options[:check_col_count]
      return {quote_errors: quote_errors,
              encoding_errors: encoding_errors,
              column_errors: column_errors}
    else
      return {quote_errors: quote_errors,
              encoding_errors: encoding_errors}
    end
    
  end
end