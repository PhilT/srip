class Rules
  def apply(info)
    info = discard_single_chapter_titles(info)
    discard_playlist_titles(info)
  end

  private

  def discard_single_chapter_titles(info)

  end

  def discard_playlist_titles(info)
    if info[:season]
      info[:titles].reject! do | value|
        value[:segment_map].match(',') && value[:segment_map].match('-')
      end
    end
    info
  end
end

