# wtf_csv
Ruby gem to detect formatting issues in a CSV

The CSV file format is meant to be an easy way to transport data. Anyone who has had to maintain an import process, however, knows that it's easy to mess up. Usually the entire landscape looks like this:
  1. An importer expects CSV files to be provided in some specific format
  2. The files are given in a different format
  3. The import fails; or even worse, the import succeeds but the data is mangled
  4. Some poor souls must dig through the CSV file to figure out what happened. Usually issues are related to bad cell quoting, inconsistent column counts, etc.
  
This gem seeks to make this process less terrible by providing a way to easily surface common formatting issues on a CSV file.

`WtfCSV.scan` has the following options:
First Header  | Second Header
------------- | -------------
Content Cell  | Content Cell
Content Cell  | Content Cell

If you happen upon this, know that this is in it's infancy. Eventually this will be available on https://rubygems.org, where you'll be able to install with `gem install wtf_csv` or putting `require 'wtf_csv'` in your gemfile. Until them, feel free to install from source and bundle it into a gem yourself - just give proper credit where it is due.

See `lib/wtf_csv/test_script.rb` for an example implementation.
