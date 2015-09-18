require 'spec_helper'

fixture_path = 'spec/fixtures'
# writing some files with special characters:
# File.write("#{fixture_path}/quoted_fields_r.csv", "\"animal\",\"sound\",color,size\r\"cat\",meow,\"calico\",small\rdog,\"bark\",\"golden\",medium\rhorse,whinny,\"brown\",\"large\"")
# File.write("#{fixture_path}/max_chars_in_field_rn.csv", "\"animal\",\"sound\",color,\"\\\"size\r\ncat\",meow,\"calico\",small_and_this_is_a_long_field_with_44_chars\r\ndog,\"field_with_26_characters\",\"golden,medium\r\nhorse,whinny\\\"\",\"brown\",\"large\"")
# File.write("#{fixture_path}/encoding.csv", "\"animal\",\"sound\",co\255lor,\"\\\"size\ncat\",meow,\"calico\",small_and_this_is_a_long_field_with_44_chars\ndog,\"field_with_26_charact\255ers\"\255,\"golden,medium\nhorse,whinny\\\"\",\"brown\",\"large\"")

describe 'a file with \n line endings' do
  it 'should have no errors' do
    options = {:row_sep => "\n"}
    output = WtfCSV.scan("#{fixture_path}/quoted_fields_n.csv", options)
    output[:quote_errors].length.should be == 0
    output[:column_errors].length.should be == 0
    output[:length_errors].length.should be == 0
    output[:encoding_errors].length.should be == 0
  end
end

describe 'a file with \r line endings' do
  it 'should have no errors' do
    options = {:row_sep => "\r"}
    output = WtfCSV.scan("#{fixture_path}/quoted_fields_r.csv", options)
    output[:quote_errors].length.should be == 0
    output[:column_errors].length.should be == 0
    output[:length_errors].length.should be == 0
    output[:encoding_errors].length.should be == 0
  end
end

describe 'a file with \r\n line endings' do
  it 'should have no errors' do
    options = {:row_sep => "\r\n"}
    output = WtfCSV.scan("#{fixture_path}/quoted_fields_rn.csv", options)
    output[:quote_errors].length.should be == 0
    output[:column_errors].length.should be == 0
    output[:length_errors].length.should be == 0
    output[:encoding_errors].length.should be == 0
  end
end

describe 'a file with pipe delimiters' do
  it 'should have no errors' do
    options = {:col_sep => '|'}
    output = WtfCSV.scan("#{fixture_path}/pipe_delimited.csv", options)
    output[:quote_errors].length.should be == 0
    output[:column_errors].length.should be == 0
    output[:length_errors].length.should be == 0
    output[:encoding_errors].length.should be == 0
  end
end

describe 'a file with custom quote characters' do
  it 'should behave correctly' do
    options = {:quote_char => '+'}
    output = WtfCSV.scan("#{fixture_path}/quote_char.csv", options)
    output[:quote_errors].length.should be == 2
    if output[:quote_errors].length == 2
      output[:quote_errors].should include [2,1,"++cat++"]
      output[:quote_errors].should include [3,4,"+medium+a"]
    end
    output[:column_errors].length.should be == 0
    output[:length_errors].length.should be == 0
    output[:encoding_errors].length.should be == 0
  end
end

describe 'a file with custom escape character' do
  it 'should behave correctly' do
    options = {:escape_char => '='}
    output = WtfCSV.scan("#{fixture_path}/escape_char.csv", options)
    output[:quote_errors].length.should be == 0
    output[:column_errors].length.should be == 0
    output[:length_errors].length.should be == 0
    output[:encoding_errors].length.should be == 0
  end
end

describe 'a file with the same escape and quote characters' do
  it 'should behave correctly' do
    options = {:escape_char => '"', :quote_char => '"'}
    output = WtfCSV.scan("#{fixture_path}/escape_char_equals_quote_char.csv", options)
    output[:quote_errors].length.should be == 1
    if output[:quote_errors].length == 1
      output[:quote_errors].should include [2,4,'"""small""']
    end
    output[:column_errors].length.should be == 0
    output[:length_errors].length.should be == 0
    output[:encoding_errors].length.should be == 0
  end
end

describe 'checking a file for a fixed number of columns in each row' do
  it 'should catch errors' do
    options = {:num_cols => 4}
    output = WtfCSV.scan("#{fixture_path}/check_column_count_fixed.csv", options)
    output[:quote_errors].length.should be == 0
    output[:column_errors].length.should be == 2
    if output[:column_errors].length == 2
      output[:column_errors].should include [2,5,4]
      output[:column_errors].should include [5,3,4]
    end
    output[:length_errors].length.should be == 0
    output[:encoding_errors].length.should be == 0
  end
end
  
describe 'checking a file for column counts and determining the number of columns with a threshold' do
  it 'should only return the counts of how many rows have different numbers of columns if under the threshold' do
    options = {:col_threshold => 70}
    output = WtfCSV.scan("#{fixture_path}/check_column_count_smart_threshold.csv", options)
    output[:quote_errors].length.should be == 0
    output[:column_errors].length.should be == 3
    if output[:column_errors].length == 3
      output[:column_errors].should include [4,3]
      output[:column_errors].should include [5,1]
      output[:column_errors].should include [3,1]
    end
    output[:length_errors].length.should be == 0
    output[:encoding_errors].length.should be == 0
  end
end

describe 'checking a file for column counts and determining the number of columns with a threshold' do
  it 'should determine the target number of columns using a threshold' do
    options = {:col_threshold => 60}
    output = WtfCSV.scan("#{fixture_path}/check_column_count_smart_threshold.csv", options)
    output[:quote_errors].length.should be == 0
    output[:column_errors].length.should be == 2
    if output[:column_errors].length == 2
      output[:column_errors].should include [2,5,4]
      output[:column_errors].should include [5,3,4]
    end
    output[:length_errors].length.should be == 0
    output[:encoding_errors].length.should be == 0
  end
end

describe 'using the :ignore_string option' do
  it 'should skip the line that matches this string' do
    options = {:ignore_string => 'ignore_this_line',
               :col_threshold => 60}
    output = WtfCSV.scan("#{fixture_path}/ignore_string.csv", options)
    output[:quote_errors].length.should be == 0
    output[:column_errors].length.should be == 1
    if output[:column_errors].length == 1
      output[:column_errors].should include [5,1,4]
    end
    output[:length_errors].length.should be == 0
    output[:encoding_errors].length.should be == 0
  end
end

describe 'a file with quoted newlines' do
  it 'should provide accurate errors if :allow_row_sep_in_quoted_fields is not set to true' do
    options = {:col_threshold => 70}
    output = WtfCSV.scan("#{fixture_path}/quoted_newlines.csv", options)
    output[:quote_errors].length.should be == 4
    if output[:quote_errors].length == 4
      output[:quote_errors].should include [1,4,'"\"size']
      output[:quote_errors].should include [2,1,'cat"']
      output[:quote_errors].should include [3,3,'"golden,medium']
      output[:quote_errors].should include [4,2,'whinny"']
    end
    output[:column_errors].length.should be == 1
    if output[:column_errors].length == 1
      output[:column_errors].should include [3,3,4]
    end
    output[:length_errors].length.should be == 0
    output[:encoding_errors].length.should be == 0
  end
end

describe 'a file with quoted newlines' do
  it 'should allow the quote newlines if :allow_row_sep_in_quoted_fields is set to true' do
    options = {:allow_row_sep_in_quoted_fields => true}
    output = WtfCSV.scan("#{fixture_path}/quoted_newlines.csv", options)
    output[:quote_errors].length.should be == 0
    output[:column_errors].length.should be == 2
    if output[:column_errors].length == 2
      output[:column_errors].should include [7,1]
      output[:column_errors].should include [5,1]
    end
    output[:length_errors].length.should be == 0
    output[:encoding_errors].length.should be == 0
  end
end

describe 'a file that has greater than the number of characters in :max_chars_in_field in a single field' do
  it 'should give appropriate errors, and should count a \n in the field as a single character' do
    options = {:max_chars_in_field => 15,
               :allow_row_sep_in_quoted_fields => true,
               :check_col_count => false}
    output = WtfCSV.scan("#{fixture_path}/max_chars_in_field_n.csv", options)
    output[:quote_errors].length.should be == 0
    output[:column_errors].length.should be == 0
    output[:length_errors].length.should be == 3
    if output[:length_errors].length == 3
      output[:length_errors].should include [1,7,44]
      output[:length_errors].should include [2,2,26]
      output[:length_errors].should include [2,3,30]
    end
    output[:encoding_errors].length.should be == 0
  end
end

describe 'a file that has greater than the number of characters in :max_chars_in_field in a single field' do
  it 'should give appropriate errors, and should count a \r\n in the field as two characters' do
    options = {:max_chars_in_field => 15,
               :allow_row_sep_in_quoted_fields => true,
               :row_sep => "\r\n",
               :check_col_count => false}
    output = WtfCSV.scan("#{fixture_path}/max_chars_in_field_rn.csv", options)
    output[:quote_errors].length.should be == 0
    output[:column_errors].length.should be == 0
    output[:length_errors].length.should be == 3
    if output[:length_errors].length == 3
      output[:length_errors].should include [1,7,44]
      output[:length_errors].should include [2,2,26]
      output[:length_errors].should include [2,3,31]
    end
    output[:encoding_errors].length.should be == 0
  end
end

describe 'a file that has encoding errors' do
  it 'should give appropriate errors' do
    options = {:allow_row_sep_in_quoted_fields => true,
               :check_col_count => false}
    output = WtfCSV.scan("#{fixture_path}/encoding.csv", options)
    output[:encoding_errors]
    output[:quote_errors].length.should be == 0
    output[:column_errors].length.should be == 0
    output[:length_errors].length.should be == 0
    output[:encoding_errors].length.should be == 3
    if output[:encoding_errors].length == 3
      output[:encoding_errors].should include [1,3]
      output[:encoding_errors].should include [2,2]
      output[:encoding_errors].each_with_index do |err, idx|
        if err == [2,2]
          output[:encoding_errors].delete_at(idx)
          break
        end
      end 
      output[:encoding_errors].should include [2,2]
    end
  end
end