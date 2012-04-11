require './parser.rb'
require 'test/unit'
require 'pp'

class TestParser < Test::Unit::TestCase
  def test_parser
    assert_equal [%w{v 3+:# 0 d}, %w{v +3 4 e}, %w{^ +2:# 3 d}, %w{v +2:# 3 d}],
                 Notedown.parse_to_array('{#|3+,5},v[3+@d|0][+3@e|4],[+2:#@d|3],[+2:#@d|3]')
  end

  def test_parse_to_json
    assert_equal "[[\"v\",\"3+:#\",\"0\",\"d\"],[\"v\",\"+3\",\"4\",\"e\"],[\"^\",\"+2:#\",\"3\",\"d\"]]",
                 Notedown.parse_to_json('{#|3+,5},v[3+@d|0][+3@e|4],[+2:#@d|3]')
  end
  
  def test_parse_from_file_to
    assert_not_nil Notedown.parse_from_file_to "sample"
  end
end

