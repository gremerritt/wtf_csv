module WtfCSV
  
	def self.scan(file, options = {}, flag = false)
	
		default_options = {
			:col_sep => ',',
			:row_sep => "\n",
			:quote_char => '"',
			:escape_char => '"',
			:verbose => false ,
      :headers_in_file => true,
      :file_encoding => 'utf-8',
    }
    options = default_options.merge(options)
    
		case options[:row_sep]
			when "\n", :lf
				options[:row_sep] = ["\n"]
			when "\r", :cr
				options[:row_sep] = ["\r"]
			when "\r\n", :crlf
				options[:row_sep] = ["\r", "\n"]
			else
				# do nothing
		end
		
	  quoteErrors = Array.new
		columnErrors = Array.new
  	charErrors = Array.new
  	
  	File.open(file) do |f|
    	
			###################################
      # INITIALIZE A BUNCH OF STUFF
      line = ""
			charPositionInLine = -1
			lineNumber = 0
			col = 0
			posStart = 0
		  posEnd = 0
		  columnCount = -1

			quoted = false
			separator = true
			escaped = false
			tmpError = false
			noQuotesInCell = false
			###################################
			
			f.each_char do |char|
			  puts "#{char} (#{char.ord})" if flag
				
				line += char
				charPositionInLine += 1
				puts "quoted: #{quoted}" if flag
				puts "noQuotesInCell: #{noQuotesInCell}" if flag
				
				begin
					if escaped
						puts "  >a" if flag
						escaped = false
						if (options[:quote_char] == options[:escape_char]) and char != options[:quote_char]
						  puts "  >a a" if flag
							quoted = !quoted
							
							if !quoted
								endOfQuote = true
							elsif noQuotesInCell
							  tmpError = true
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
						if endOfQuote
						  tmpError = true
						  endOfQuote = false
						end
						
						if !quoted
						  noQuotesInCell = true
						end
						
						next
					end
					
					if char == options[:escape_char]
						puts "  >c" if flag
						escaped = true
						next
					end
					
					if char == options[:col_sep] and !quoted
						puts "  >d" if flag
						if tmpError
							quoteErrors.push("#{lineNumber + 1},#{col + 1},#{line[posStart..(charPositionInLine - 1)]}")
							tmpError = false
						end
						
						posStart = charPositionInLine + 1
						noQuotesInCell = false
						col += 1
					end
					
					if char == options[:quote_char]
						puts "  >e" if flag
						quoted = true
						
						if noQuotesInCell
						  tmpError = true
						end
					end
					
					if options[:row_sep].include? char
						puts "  >f (#{(options[:row_sep][0]).ord})" if flag
						if options[:row_sep][0] == "\n" and char == "\n"
							puts "  >g" if flag
							
							if quoted
							  tmpError = true
							end
							
							if tmpError
								quoteErrors.push("#{lineNumber + 1},#{col + 1},#{line[posStart..(charPositionInLine - 1)]}")
								tmpError = false
							end
				
							if columnCount == -1
							  columnCount = col + 1
							end
							
							if (col + 1) != columnCount
								columnErrors.push("#{lineNumber + 1},#{col + 1},#{columnCount}")
							end
							
							lineNumber += 1
							charPositionInLine = -1
							line = ""
							col = 0
							posStart = 0
							quoted = false
							noQuotesInCell = false
						end
					end
					
				rescue Exception => ex
					#puts ex
					# who cares? probably not a UTF-8 character, or we're doing .ord on a null class
				end
			end
  	end
		
		return {quote_errors: quoteErrors,
						column_errors: columnErrors,
						char_errors: charErrors}
	end

end