class Actions
  def initialize(ripper_class)
    @ripper = ripper_class.new(SETTINGS.temp, SETTINGS.min_length)
  end

  def cancel
    @ripper.cancel
  end

  def eject
    `eject`
  end

  def clear_temp_folder
    `rm -f #{File.join(SETTINGS.temp, '*.*')}`
  end

  def disc_info
    info = {}
    output = @ripper.info
    if output.nil?
      info[:error] = "Problem reading disc. Check it's inserted correctly"
    else
      info = Disc.new.info(output)

      if info[:id].nil?
        info[:error] = 'Could not get disc info. Check you can open the disc in makemkv.'
      else
        write_log(output, info[:id], 'info')
      end
    end
    info
  end

  def rip_disc(id)
    output = @ripper.rip(id)
    write_log(output, info[:id], 'rip')
  end

  def search(title, matches)
    imdb = Imdb::Search.new(title)
    matches.list = imdb.movies[0..50].map(&:title)
  end

  def set_library_path(info, owned)
    info[:library] = library_path(owned, info[:season] ? 'Shows' : 'Movies')
  end

  def library_path(owned, type)
    if owned
      File.join(SETTINGS.owned, type)
    else
      File.join(SETTINGS.rented, type)
    end
  end

  def apply_rules(info)
    info = Rules.new.apply(info)
    File.write(File.join(SETTINGS.log, "#{info[:id]}.yml"), info.to_yaml)
    info
  end

  private

  def write_log(output, name, type)
    path = File.join(SETTINGS.log, "#{name}_#{type}.txt")
    File.write(path, output)
  end
end
