require './test/test_helper'

class Ripper
  def `(*args)
    "EXEC #{args.join(' ')}"
  end
end

class RipperTest < Minitest::Test
  def setup
   FakeFS.activate!
   FakeFS::FileSystem.clear
    FileUtils.mkdir_p('tempdir')
    FileUtils.rm('tempdir/ripper.log') if File.exists?('tempdir/ripper.log')
  end

  def teardown
    FakeFS.deactivate!
  end

  def assert_equal(expected, actual)
    assert expected == actual, "Expected: #{expected}\n but was: #{actual}"
  end

  def test_info_call_makemkv_with_info_command
    info = Ripper.new.info('tempdir', 3000)

    cmd = 'makemkvcon --robot --minlength=3000 info disc:0'
    assert_equal "#{cmd}\nEXEC #{cmd}", info
  end

  def test_rip_calls_makemkv_with_mkv_command
    Ripper.new.rip('tempdir', 'id', 3000)

    cmd = 'makemkvcon --robot --minlength=3000 mkv disc:0 id tempdir'
    log_file = File.read('tempdir/ripper.log')
    assert_equal "#{cmd}\nEXEC #{cmd}\n", log_file
  end
end
