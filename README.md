# WtfCSV
`wtf_csv` is a Ruby Gem to detect formatting issues in a CSV

### Motivation

The CSV file format is meant to be an easy way to transport data. Anyone who has had to maintain an import process, however, knows that it's easy to mess up. Usually the entire landscape looks like this:
  1. An importer expects CSV files to be provided in some specific format
  2. The files are given in a different format
  3. The import fails; or even worse, the import succeeds but the data is mangled
  4. Some poor soul must dig through the CSV file to figure out what happened. Usually issues are related to bad cell quoting, inconsistent column counts, etc.
  
This gem seeks to make this process less terrible by providing a way to easily surface common formatting issues in a CSV file.

## Documentation

`WtfCSV.scan` will return a hash with four keys: `:quote_errors`, `:encoding_errors`, `:column_errors`, and `:length_errors`. Each key's value will be an array of the issues that were found including information about the issue, in the format described below.

### :quote_errors
`[<line number>, <column_number<, <text of the improperly quoted field>]`

### :encoding_errors
`[<line number>, <column number>]`

### :column_errors
This array will always be empty if the `:check_col_count` is set to `false`

If `WtfCSV.scan` was able to determine how many columns should be in each row, either by using the `:col_threshold` option or because the `:num_cols` option was set, the format will be:

`[<line number>, <number of columns in the line>, <number of columns that should be in the line>]`

If `WtfCSV.scan` wasn't able to determine how many columns should be in each row (because an adequate number of columns weren't above the `:col_threshold` percentage) the format will be:

`[<number of columns>, <number of rows that have this number of columns>]`

### :length_errors
This array will always be empty unless the `:max_chars_in_field` option is being used

`[<line number>, <column number>, <field length>]`

## Configuration

`WtfCSV.scan` has the following options:
```
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
| :ignore_string                  |   nil    | If a line is equal to this string, the line will not be checked for issues           |
|---------------------------------|----------|--------------------------------------------------------------------------------------|
| :allow_row_sep_in_quoted_fields |  false   | Allows :row_sep characters to be present in quoted fields. Otherwise if there are    |
|                                 |          | line ending characters in a field, they will be treat as sequential lines and you'll |
|                                 |          | likely receive column count errors (if you're checking for them)                     |
|---------------------------------|----------|--------------------------------------------------------------------------------------|
| :max_chars_in_field             |   nil    | Ensures that fields have less than or equal to the provided number of characters     |
|---------------------------------|----------|--------------------------------------------------------------------------------------|
| :file_encoding                  | 'utf-8'  | Set the file encoding                                                                |
|---------------------------------|----------|--------------------------------------------------------------------------------------|
```

## Installation

Add this line to your application's Gemfile:

    gem 'wtf_csv'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install wtf_csv

## Bugs and Feature Requests

Please [open an Issue on GitHub](https://github.com/gremerritt/wtf_csv/issues) with any bugs or feature requests. Thanks!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b new-feature`)
3. Commit your changes (`git commit -am 'adds a new feature'`)
4. Push to the branch (`git push origin new-feature`)
5. Create new Pull Request