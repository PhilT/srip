require 'fileutils'
require './lib/immutable'

class Library
  def initialize(info)
    @info = info
  end

  def add_all
    dir = File.dirname(path)
    unless Dir.exist?(dir)
      `sudo mkdir -p "#{dir}"`
      `sudo chown plex:plex "#{dir}"`
    end

    warnings = []
    @info[:titles].each do |title|
      tempfile = File.join(Actions::TEMP_DIR, title[:filename])
      `sudo chown plex:plex "#{tempfile}"`
      `sudo mv "#{tempfile}" "#{path}"`

      warnings << check_filesize
    end
    warnings.compact.first
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
      "WARNING: #{path} is less than 1GB"
    end
  end
end
