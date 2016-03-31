require 'fileutils'
require './lib/immutable'

class Library
  extend Immutable

  def initialize(info, title)
    @info = info
    @title = title
  end

  def add
    FileUtils.mkdir_p File.dirname(path)
#    FileUtils.chown_R 'plex', 'plex', File.dirname(path)
    FileUtils.mv File.join(@info[:tempdir], @title[:filename]), path
#    FileUtils.chown 'plex', 'plex', path
    check_filesize
  end

  def path
    @info[:season] ? episode_path : movie_path
  end

  def episode_path
    season_dir = File.join(@info[:library], @info[:name], "Season #{@info[:season]}")
    files_in_season = Dir[File.join(season_dir, '/*.mkv')]
    episode = last_episode(files_in_season) + 1
    name = "#{@info[:name]} - s#{@info[:season]}e#{'%02d' % episode}.mkv"
    File.join(season_dir, name)
  end

  def movie_path
    File.join(@info[:library], "#{@info[:name]} (#{@info[:year]}).mkv")
  end

  def last_episode(files)
    files.map do |file|
      file.match(/\w - s.*?e(.*?)\.mkv/)[1].to_i
    end.sort.last.to_i
  end

  private

  def check_filesize
    filesize = File.size(path)
    if filesize < (1024 * 1024 * 1024)
      puts "WARNING: #{path} is less an 1GB"
    end
  end
end
