# wtf_csv
Ruby gem to detect formatting issues in a CSV

The CSV file format is meant to be an easy way to transport data. Anyone who has had to maintain an import process, however, knows that it's easy to mess up. Usually the entire landscape looks like this:
  1. An importer expects CSV files to be provided in some specific format
  2. The files are given in a different format
  3. The import fails; or even worse, the import succeeds but the data is mangled
  4. Some poor souls must dig through the CSV file to figure out what happened. Usually issues are related to bad cell quoting, inconsistent column counts, etc.
  
This gem seeks to make this process less terrible by providing a way to easily surface common formatting issues on a CSV file.

`WtfCSV.scan` has the following options:
    |---------------------------------|----------|--------------------------------------------------------------------------------------|
    | Option                          | Default  |  Explanation                                                                         |
    |---------------------------------|----------|--------------------------------------------------------------------------------------|
    | :col_sep                        |   ','    | Column separator                                                                     |
    | :row_sep                        | $/ ,"\n" | Row separator - defaults to system's $/ , which defaults to "\n"                     |
    |                                 |          | This can also be set to :auto, but will process the whole cvs file first  (slow!)    |
    | :quote_char                     |   '"'    | Quotation character                                                                  |
    | :escape_char                    |   '\'    | Character to escape quotes                                                           |
    |---------------------------------|----------|--------------------------------------------------------------------------------------|
    | :check_col_count                |   true   | If set, checks for issues in the number of columns that are present                  |
    | :num_cols                       |    0     | If :check_col_count is set and this value is non-zero, will return errors if any     |
    |                                 |          | line does not have this number of columns                                            |
    | :col_threshold                  |    80    | If :check_col_count is set, this is the percentage of rows that must have a column   |
    |                                 |          | count in order for the module to assume this is the target number of columns.        |
    |                                 |          |   For example, if there are 10 line in the file, and this value is set to 80, then   |
    |                                 |          |   at least 8 lines must have a certain number of columns for the module to assume    |
    |                                 |          |   this is the number of columns that rows are supposed to have                       |
    |---------------------------------|----------|--------------------------------------------------------------------------------------|
    | :allow_row_sep_in_quoted_fields |  false   | Allows :row_sep characters to be present in quoted fields. Otherwise if there are    |
    |                                 |          | line ending characters in a field, they will be treat as sequential lines and you'll |
    |                                 |          | likely receive column count errors (if you're checking for them)                     |
    |---------------------------------|----------|--------------------------------------------------------------------------------------|
    | :file_encoding                  | 'utf-8'  | Set the file encoding
    |---------------------------------|----------|--------------------------------------------------------------------------------------|

If you happen upon this, know that this is in it's infancy. Eventually this will be available on https://rubygems.org, where you'll be able to install with `gem install wtf_csv` or putting `require 'wtf_csv'` in your gemfile. Until them, feel free to install from source and bundle it into a gem yourself - just give proper credit where it is due.

See `lib/wtf_csv/test_script.rb` for an example implementation.
