class Rules
  def apply(info)
    info = discard_single_chapter_titles(info)
    info[:season] ? discard_playlist_titles(info) : select_first_title(info)
  end

  private

  def select_first_title(info)
    info.dup.tap { |i| i[:titles] = [i[:titles].first] }
  end

  def discard_single_chapter_titles(info)
    info.dup.tap do |i|
      i[:titles].reject! do |title|
        title[:chapters] == 1
      end
    end
  end

  def discard_playlist_titles(info)
    info.dup.tap do |i|
      i[:titles].reject! do | title|
        title[:segment_map].match(',') && title[:segment_map].match('-')
      end
    end
  end
end
