class Rules

  def apply(info)
    info = discard_single_chapter_titles(info)
    discard_playlist_titles(info)
  end

  private

  def discard_single_chapter_titles(info)
    info[:titles].reject! do |title|
      title[:chapters] == 1
    end
    info
  end

  def discard_playlist_titles(info)
    if info[:season]
      #FIXME: reject! is mutable
      info[:titles].reject! do | title|
        title[:segment_map].match(',') && title[:segment_map].match('-')
      end
    end
    info
  end
end

