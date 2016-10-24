class DriveDetector
  def initialize(view, inserted_method, logger)
    @view = view
    @logger = logger
    @inserted_method = inserted_method
    @inserted = false
  end

  def target_drive?(drive)
    drive.get_identifier('unix-device') == SETTINGS['drive']
  end

  def changing(drive)
    return if @changing || @view.title_in_tmp? || !target_drive?(drive)
    @changing = true
    GLib::Timeout.add(2000) { changed }
  end

  def changed
    if @changing
      @changing = false
      @inserted = !@inserted
      if @inserted
        @logger.info 'Disc inserted'
        @view.send(@inserted_method)
      else
        @logger.info 'Disc ejected'
      end
    end
    false
  end

  def added(volume)
    return if @view.title_in_tmp? || !target_drive?(volume)
    @changing = false
    @inserted = true
    @logger.info 'Disc inserted'
    @view.send(@inserted_method)
  end

  def removed(volume)
    return unless target_drive?(volume)
    @changing = false
    @inserted = false
    @logger.info 'Disc ejected'
  end
end
