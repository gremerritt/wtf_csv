module WtfCSV
  def self.scan(file, options = {}, flag = false)
    
    default_options = {
      :col_sep => ',',
      :row_sep => "\n",
      :quote_char => '"',
      :escape_char => '"',
      :row_sep_in_quoted_fields => false,
      :file_encoding => 'utf-8',
    }
    options = default_options.merge(options)
    
#     case options[:row_sep]
#       when "\n", :lf
#         options[:row_sep] = ["\n"]
#       when "\r", :cr
#         options[:row_sep] = ["\r"]
#       when "\r\n", :crlf
#         options[:row_sep] = ["\r", "\n"]
#       else
#         # do nothing
#     end
    
    File.write("test_csv.csv","header1,header2\n\"valA\"\",valB\"\nvalC,valD")
    
    quoteErrors = Array.new
    columnErrors = Array.new
    charErrors = Array.new
    
    separator = true
    escaped = false
    tmpError = false
    isQuoted = false
    wasQuoted = false
    willNotBeQuoted = false
    
    posStart = 0
    lineNumber = -1  # not using with_index on the loop because it needs to be scoped outside the loop
    col = 0
    columnCount = 0
    prevLine = ""
    
    File.foreach(file, options[:row_sep]) do |line|
      if flag
        puts "line ##{lineNumber + 1}: #{line}"
        puts "col: #{col}"
        puts "columnCount: #{columnCount}"
      end
      
      if col > 0 and columnCount == 0
        columnCount = col + 1
      end
      
      if columnCount > 0 and ((col + 1) != columnCount)
        columnErrors.push("#{lineNumber + 1},#{col + 1},#{columnCount}")
      end
      
      if isQuoted
        if options[:row_sep] == "\r\n"
          offset = 3
        else
          offset = 2
        end
        quoteErrors.push("#{lineNumber + 1},#{col + 1},#{prevLine[posStart..(prevLine.length - offset)]}")
      end
      prevLine = line
      
      separator = true
      escaped = false
      tmpError = false
      isQuoted = false
      willNotBeQuoted = false
      wasQuoted = false
      
      posStart = 0
      lineNumber += 1
      col = 0
      
      line.each_char.with_index do |char, charPositionInLine|
        if flag
          puts "\n#{char} (#{char.ord})"
          puts "isQuoted:        #{isQuoted}"
          puts "willNotBeQuoted: #{willNotBeQuoted}"
          puts "wasQuoted:       #{wasQuoted}"
        end
        
        begin
          if escaped
            puts "  >a" if flag
            escaped = false
            if (options[:quote_char] == options[:escape_char]) and char != options[:quote_char]
              puts "  >a a" if flag
              
              if !isQuoted and willNotBeQuoted
                tmpError = true
              else
                isQuoted = !isQuoted
                wasQuoted = true if !isQuoted
              end
              
            else
              puts "  >a b" if flag
              next
            end
          end
          
          if char.ord > 255
            charErrors.push("#{lineNumber + 1},#{charPositionInLine},#{char.ord}")
            next
          end
          
          if char != options[:quote_char] and char != options[:escape_char] and char != options[:col_sep] and not options[:row_sep].include? char
            puts "  >b" if flag
            if wasQuoted
              tmpError = true
              wasQuoted = false
            end
             
            if !isQuoted
              willNotBeQuoted = true
            end
            
            next
          end
          
          if char == options[:escape_char]
            puts "  >c" if flag
            escaped = true
            next
          end
          
          if char == options[:col_sep] and !isQuoted
            puts "  >d" if flag
            if tmpError
              quoteErrors.push("#{lineNumber + 1},#{col + 1},#{line[posStart..(charPositionInLine - 1)]}")
              tmpError = false
            end
            
            posStart = charPositionInLine + 1
            willNotBeQuoted = false
            col += 1
          end
          
          if char == options[:quote_char]
            puts "  >e" if flag
            
            if willNotBeQuoted
              tmpError = true
            else
              isQuoted = true
            end
          end
        
        rescue Exception => msg
          # puts msg
        end
      end
    end
    
    # we still need to check that the last line/cell is ok
    if isQuoted
      if options[:row_sep] == "\r\n"
        offset = 3
      else
        offset = 2
      end
      quoteErrors.push("#{lineNumber + 1},#{col + 1},#{prevLine[posStart..(prevLine.length - offset)]}")
    end
    
    if columnCount > 0 and ((col + 1) != columnCount)
      columnErrors.push("#{lineNumber + 1},#{col + 1},#{columnCount}")
    end
    
    return {quote_errors: quoteErrors,
            column_errors: columnErrors,
            char_errors: charErrors}
  end
end