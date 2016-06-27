class Actions
  TEMP_DIR = '/media/tmp'
  MIN_LENGTH = 45

  def clear_temp_folder
    `rm -f #{File.join(TEMP_DIR, '*.*')}`
  end

  def disc_info
      @info = YAML.load(File.read 'test/discinfo/BLADE_DVD.yml')
#      info = {}
#      output = Ripper.new.info(TEMP_DIR, MIN_LENGTH)
#      if output.nil?
#        info[:error] = "Problem reading disc. Check it's inserted correctly"
#      else
#        info = Disc.new.info(output)
#
#        if info[:id].nil?
#          info[:error] = 'Could not get disc info. Check you can open the disc in makemkv.'
#        else
#          File.write('test/discinfo/' + info[:id] + '.txt', output)
#        end
#      end
#      info
#    end
  end

  def search(title, matches)
    imdb = Imdb::Search.new(title)
    matches.list = imdb.movies[0..50].map(&:title)
  end

  def set_library_path(info, owned)
    if info[:season]
      info[:library] = library_path(owned, 'Shows')
      log_season(logger, info)
    else
      info[:titles] = [info[:titles].first]
      info[:library] = library_path(owned, 'Movies')
    end
  end

  def library_path(owned, type)
    if owned
      File.join('/media/Owned', type)
    else
      File.join('/media/Rented', type)
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

  def rip_and_eject(logger, titles)
    titles.each do |title|
      logger.info "Ripping title #{title[:id]}..."
      Ripper.new.rip(TEMP_DIR, title[:id], MIN_LENGTH)
    end

    `eject`
  end
end
