class MockRipper
  def initialize(tempdir, minlength)
    @tempdir = tempdir
    @minlength = minlength
  end

  def info
    File.read('test/support/makemkv_info.log')
  end

  def rip(id)
    5.times.each do
      File.open(File.join(@tempdir, 'title01.mkv'), 'a') do |f|
        f.puts '1234567890'
      end

      sleep 2
    end
  end
end
