class Actions
  def initialize(ripper_class)
    @ripper = ripper_class.new(TEMP_DIR, MIN_LENGTH)
  end

  def cancel
    @ripper.cancel
  end

  def clear_temp_folder
    `rm -f #{File.join(TEMP_DIR, '*.*')}`
  end

  def label
    @ripper.label
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
      end
    end
    info
  end

  def rip_disc(id)
    @ripper.rip(id)
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
      File.join(OWNED_PATH, type)
    else
      File.join(RENTED_PATH, type)
    end
  end

  def apply_rules(info)
    info = Rules.new.apply(info)
    File.write(File.join(LOG_PATH, "#{info[:id]}.yml"), info.to_yaml)
    info
  end
end
