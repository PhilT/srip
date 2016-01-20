require 'minitest/autorun'
require './lib/rules'

class RulesTest < Minitest::Test
  def test_discard_playlist_titles
    info = {
      season: 1,
      titles: [
        { segment_map: '1,2,3,4' },
        { segment_map: '1-3,4-5' },
        { segment_map: '1-4' }
      ]
    }
    assert_equal [{ segment_map: '1,2,3,4' }, { segment_map: '1-4' }], Rules.new.apply(info)[:titles]
  end

  def test_discard_single_chapter_titles
    info = {
      titles: [
        { chapters: 2 },
        { chapters: 3 },
        { chapters: 1 }
      ]
    }
    assert_equal [{ chapters: 2 }, { chapters: 3 }], Rules.new.apply(info)[:titles]
  end
end

