class Library
  class RipError; end

  def file(options)
    options[:titles].each do |title|
      Ripper.new.rip(options[:tempdir], title[:id])

      filesize = File.size(title[:filename])
      if filesize != title[:size_in_bytes]
        raise RipError, "#{title[:filename]} file size of #{filesize} does not match disc size of #{title[:size_in_bytes]}"
      end

      if info[:season]
        dir = File.join(options[:library], info[:name], info[:season])
        episode = last_episode(dir) + 1
        name = "#{info[:name]} - s#{info[:season]}e#{'%02d' % episode}.mkv"
        path = File.join(dir, name)
      else
        path = File.join(options[:library], "#{info[:name]} (#{year})")
      end
      FileUtils.mv File.join(options[:tempdir], title[:filename]), path
    end
  end

  private

  def last_episode(path)
    Dir[File.join(path, '/*.mkv')].map{|file| file.match(/BSG - s.*?e(.*?)\.mkv/)[1].to_i }.sort.last.to_i
  end
end

