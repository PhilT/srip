require './test/test_helper'

class LibraryTest < Minitest::Test
  def setup
   FakeFS.activate!
   FakeFS::FileSystem.clear
  end

  def teardown
    FakeFS.deactivate!
  end

  def info
    @info ||= {
      tempdir: 'media',
      library: 'media/Owned',
      name: 'Series',
      season: 1
    }
  end

  def title
    { filename: 'title0.mkv' }
  end

  def subject
    Library.new(info, title)
  end

  def series_path
    @series_path ||= 'media/Owned/Series/Season 1/Series - s1e01.mkv'
  end

  def assert_path(expected)
    assert expected == subject.path, "Expected #{expected} but was #{subject.path}"
  end

  def test_add_first_episode
    FileUtils.mkdir_p 'media'
    FileUtils.touch 'media/title0.mkv'
    subject.add
    assert File.exists?(series_path)
  end

  def create_files
    FileUtils.mkdir_p 'media/Owned/Series/Season 1'
    FileUtils.touch 'media/title0.mkv'
  end

  def test_add_moves_file_to_correct_location
    create_files
    FileUtils.touch series_path

    subject.add

    assert File.exists?(series_path)
    assert !File.exists?('media/title0.mkv')
  end

  def assert_equal(expected, actual)
    assert expected == actual, "Expected: #{expected}\n but got: #{actual}"
  end

  def test_add_warns_when_file_smaller_than_1gb
    create_files

    assert_equal "WARNING: #{series_path} is less than 1GB", subject.add
  end

  def test_path_returns_movie_path
    @info = info.merge(name: 'Movie', season: nil, year: '1990')
    assert_path 'media/Owned/Movie (1990).mkv'
  end

  def test_path_returns_the_same_tv_show_path
    assert_path series_path
    assert_path series_path
  end

  def test_last_episode_low_season_and_episode
    assert_equal 3, subject.last_episode(['Series Name - s1e03.mkv', 'Series Name - s1e02.mkv'])
  end

  def test_last_episode_high_season_and_episode
    assert_equal 11, subject.last_episode(['Series Name - s10e10.mkv', 'Series Name - s10e11.mkv'])
  end
end
