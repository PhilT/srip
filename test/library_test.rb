require 'minitest/autorun'
require './lib/library'

class LibraryTest < Minitest::Test
  def info
    {
      tempdir: '/media',
      library: '/media/Owned',
      name: 'Series',
      season: 1
    }
  end

  def title
    {
      filename: 'title0.mkv'
    }
  end

  def store
    @store ||= Minitest::Mock.new
  end

  def subject
    Library.new(info, title, store)
  end

  def test_add
    store.expect :files_in_dir, ['Series - s1e01.mkv'], ['/media/Owned/Series/Season 1/*.mkv']
    store.expect :move, nil, ['/media/title0.mkv', '/media/Owned/Series/Season 1/Series - s1e02.mkv']
    subject.add
    store.verify
  end

  def test_last_episode
    assert_equal 3, subject.last_episode(['Series Name - s1e03.mkv', 'Series Name - s1e02.mkv'])
    assert_equal 11, subject.last_episode(['Series Name - s10e10.mkv', 'Series Name - s10e11.mkv'])
  end
end

