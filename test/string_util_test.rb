require 'minitest/autorun'
require './lib/string_util'

class StringUtilTest < Minitest::Test
  include StringUtil

  def test_titleize_with_underscores
    assert_equal 'This Is A Title', titleize('THIS_IS_A_TITLE')
  end

  def test_titleize_with_spaces
    assert_equal 'This Is A Title', titleize('THIS IS A TITLE')
  end
end

