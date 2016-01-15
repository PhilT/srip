class Library
  include Immutable
  class RipError; end

  def initialize(info, title, store)
    @info = info
    @title = title
    @store = store
  end

  def add(info, title, store)
    store::move File.join(info[:tempdir], title[:filename]), path
  end

  def path
    @info[:season] ? episode_path : movie_path
  end

  def episode_path
    season_dir = File.join(info[:library], info[:name], info[:season])
    files_in_season = store::files_in_dir(File.join(season_dir, '/*.mkv'))
    episode = last_episode(files_in_season) + 1
    name = "#{info[:name]} - s#{info[:season]}e#{'%02d' % episode}.mkv"
    File.join(dir, name)
  end

  def movie_path
    File.join(info[:library], "#{info[:name]} (#{year})")
  end

  def last_episode(files)
    files.map do |file|
      file.match(/\w - s.*?e(.*?)\.mkv/)[1].to_i
    end.sort.last.to_i
  end
end

