require './parser.rb'

File.open "sample_parse_result.json", "w+" do |f|
  f.write Notedown.parse_from_file_to("sample")
end