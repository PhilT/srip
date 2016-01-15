require 'minitest/autorun'
require './lib/library'

class LibraryTest < Minitest::Test

  def store
    mock 'Store', files_in_dir:
  end

  def subject
    Library.new(info, title, store)
  end

  def test_last_episode
    assert_equal 3, last_episode(['Series Name - s1e03.mkv', 'Series Name - s1e02.mkv'])
    assert_equal 11, last_episode(['Series Name - s10e10.mkv', 'Series Name - s10e11.mkv'])
  end
end

