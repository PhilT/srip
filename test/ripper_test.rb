require './test/test_helper'

class Ripper
  def `(*args)
    "EXEC #{args.join(' ')}"
  end
end

class RipperTest < Minitest::Test
  def setup
    FakeFS.activate!
    FileUtils.mkdir_p('tempdir')
    FileUtils.rm('tempdir/ripper.log') if File.exists?('tempdir/ripper.log')
  end

  def test_info_call_makemkv_with_info_command
    info = Ripper.new.info('tempdir')

    FakeFS.deactivate!
    cmd = 'makemkvcon --robot --minlength=1800 info disc:0'
    assert_equal "#{cmd}\nEXEC #{cmd}", info
  end

  def test_rip_calls_makemkv_with_mkv_command
    Ripper.new.rip('tempdir', 'id', '3000')

    cmd = 'makemkvcon --robot --minlength=3000 mkv disc:0 id tempdir'
    log_file = File.read('tempdir/ripper.log')
    FakeFS.deactivate!
    assert_equal "#{cmd}\nEXEC #{cmd}\n", log_file
  end
end
