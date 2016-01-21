require './test/test_helper'

class LibraryTest < Minitest::Test
  def setup
    FakeFS.activate!
  end

  def teardown
    FakeFS.deactivate!
  end

  def info
    @info ||= {
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

  def subject
    Library.new(info, title)
  end

  def test_add
    FileUtils.mkdir_p '/media/Owned/Series/Season 1'
    FileUtils.touch '/media/Owned/Series/Season 1/Series - s1e01.mkv'
    FileUtils.touch '/media/title0.mkv'

    subject.add

    assert File.exists?('/media/Owned/Series/Season 1/Series - s1e02.mkv')
    assert !File.exists?('/media/title0.mkv')
  end

  def test_path_returns_movie_path
    @info = info.merge(name: 'Movie', season: nil, year: '1990')
    assert_equal '/media/Owned/Movie (1990).mkv', subject.path
  end

  def test_path_returns_tv_show_path

  end

  def test_last_episode_low_season_and_episode
    assert_equal 3, subject.last_episode(['Series Name - s1e03.mkv', 'Series Name - s1e02.mkv'])
  end

  def test_last_episode_high_season_and_episode
    assert_equal 11, subject.last_episode(['Series Name - s10e10.mkv', 'Series Name - s10e11.mkv'])
  end
end

