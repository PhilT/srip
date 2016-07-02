require 'fileutils'

class Library
  def initialize(info)
    @info = info
    @episodes = []
  end

  def add_all
    dir = File.dirname(path)
    unless Dir.exist?(dir)
      `sudo mkdir -p "#{dir}"`
      `sudo chown plex:plex "#{dir}"`
    end

    errors = []
    @info[:titles].each do |title|
      tempfile = File.join(SETTINGS.temp, title[:filename])
      if File.exist?(tempfile)
        `sudo chown plex:plex "#{tempfile}"`
        `sudo mv "#{tempfile}" "#{path}"`
        errors << check_filesize
      else
        errors << "#{tempfile} not copied correctly. Check log for details"
      end
    end
    errors
  end

  def path
    @info[:season] ? episode_path : movie_path
  end

  def name
    @info[:season] ? show_name : movie_name
  end

  def episode_path
    season_dir = File.join(@info[:library], @info[:name], "Season #{@info[:season]}")
    files_in_season = Dir[File.join(season_dir, '/*.mkv')]
    episode = last_episode(files_in_season) + 1
    @episodes << episode
    episode_name = "#{@info[:name]} - s#{@info[:season]}e#{'%02d' % episode}.mkv"
    File.join(season_dir, episode_name)
  end

  def movie_path
    File.join(@info[:library], "#{movie_name}.mkv")
  end

  def movie_name
    disc = " - disc#{@info[:disc]}" if @info[:disc] != '0'
   "#{@info[:name]} (#{@info[:year]})#{disc}"
  end

  def show_name
    "#{@info[:name]} Season #{@info[:season]} Episodes #{@episodes.first} to #{@episodes.last}"
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
