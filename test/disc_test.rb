require 'minitest/autorun'
require './lib/disc'

class DiscTest < Minitest::Test
  include Disc

  def test_to_seconds
    assert_equal 0, Disc::to_seconds('0:0:0')
    assert_equal 1, Disc::to_seconds('0:0:1')
    assert_equal 60, Disc::to_seconds('0:1:0')
    assert_equal 3600, Disc::to_seconds('1:0:0')
    assert_equal 3661, Disc::to_seconds('1:1:1')
    assert_equal 219599, Disc::to_seconds('60:59:59')
  end

  def test_titles_are_added_to_info
    info = Disc::info(File.read('test/discinfo/Prince Of Persia: The Sands Of Time.txt'))
    assert_equal [0, 1, 2], info[:titles].map{|t| t[:id]}
  end
end

