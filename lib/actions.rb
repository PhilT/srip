class Actions
  #TODO: Create settings page
  TEMP_DIR = '/media/tmp'
  OWNED_PATH = '/media/Owned'
  RENTED_PATH = 'media/Rented'
  MIN_LENGTH = 45

  def initialize(ripperClass)
    @ripper = ripperClass.new(TEMP_DIR, MIN_LENGTH)
  end

  def clear_temp_folder
    `rm -f #{File.join(TEMP_DIR, '*.*')}`
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
        File.write('test/discinfo/' + info[:id] + '.txt', output)
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
    if info[:season]
      info[:library] = library_path(owned, 'Shows')
      log_season(logger, info)
    elsif info[:titles]
      info[:titles] = [info[:titles].first]
      info[:library] = library_path(owned, 'Movies')
    end
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
    File.write('test/discinfo/' + info[:id] + '.yml', info.to_yaml)
    info
  end

  def log_season(logger, info)
    logger.info "Season #{info[:season]}"
    count = info[:titles].size
    logger.info "#{count} episode(s) #{MIN_LENGTH / 60} minutes or longer"
  end
end
