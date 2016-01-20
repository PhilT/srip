require 'minitest/autorun'
require './lib/disc'
require './lib/string_util'

class DiscTest < Minitest::Test
  include StringUtil

  def subject
    Disc.new
  end

  def header
    <<~EOS
    MSG:1005,0,1,"MakeMKV started"
    DRV:1,256,999,0,"","",""
    TCOUNT:2
    CINFO:1,6209,"Blu-ray"
    CINFO:2,0,"Movie Name"
    EOS
  end

  def first_title
    <<~EOS
    TINFO:0,2,0,"Movie Name"
    TINFO:0,8,0,"1"
    TINFO:0,9,0,"2:10:36"
    TINFO:0,11,0,"28189612032"
    TINFO:0,25,0,"184"
    TINFO:0,27,0,"title_t00.mkv"
    TINFO:0,33,0,"0"
    EOS
  end

  def second_title
    <<~EOS
    TINFO:1,2,0,"Movie Name"
    TINFO:1,8,0,"20"
    TINFO:1,9,0,"2:10:36"
    TINFO:1,11,0,"27388459008"
    TINFO:1,25,0,"184"
    TINFO:1,27,0,"title_t01.mkv"
    TINFO:1,33,0,"0"
    EOS
  end

  def test_titles_are_added_to_info
    info = subject.info(header + first_title + second_title)
    expected = {
      name: 'Movie Name',
      type: 'BLURAY',
      titles: [{
        id: 0,
        name: 'Movie Name',
        chapters: 1,
        duration: 7836,
        size_in_bytes: 28189612032,
        segment_count: 184,
        filename: 'title_t00.mkv',
        order: 0
      }, {
        id: 1,
        name: 'Movie Name',
        chapters: 20,
        duration: 7836,
        size_in_bytes: 27388459008,
        segment_count: 184,
        filename: 'title_t01.mkv',
        order: 0
      }]}
    assert_equal expected, info
  end

  def test_noop_returns_original_value
    assert_equal 'value', subject.noop('value')
  end

  def test_to_i_converts_value_to_integer
    assert_equal 123, subject.to_i('123')
  end

  def test_to_seconds_converts_a_time_to_seconds
    assert_equal 0, subject.to_seconds('0:0:0')
    assert_equal 1, subject.to_seconds('0:0:1')
    assert_equal 60, subject.to_seconds('0:1:0')
    assert_equal 3600, subject.to_seconds('1:0:0')
    assert_equal 3661, subject.to_seconds('1:1:1')
    assert_equal 219599, subject.to_seconds('60:59:59')
  end
end

