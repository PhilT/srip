require 'minitest/autorun'
require 'fakefs/safe'
require './lib/ripper'

class Ripper
  def `(*args)
    "EXEC #{args.join(' ')}"
  end
end

class RipperTest < Minitest::Test
  def test_info_call_makemkv_with_info_command
    cmd = 'makemkvcon --robot --minlength=1800 info disc:0'
    assert_equal "#{cmd}\nEXEC #{cmd}", Ripper.new.info
  end

  def test_rip_calls_makemkv_with_mkv_command
    log_file = nil
    FakeFS do
      FileUtils.mkdir_p('tempdir')
      Ripper.new.rip('tempdir', 'id')
      log_file = File.read('tempdir/ripper.log')
    end
    cmd = 'makemkvcon --robot --minlength=1800 mkv disc:0 id tempdir'
    assert_equal "#{cmd}\nEXEC #{cmd}\n", log_file
  end
end

