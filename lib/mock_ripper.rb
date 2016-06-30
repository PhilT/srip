class MockRipper
  def initialize(tempdir, minlength)
    @tempdir = tempdir
    @minlength = minlength
    @count = 0
  end

  def label
    'TEST_MOVIE'
  end

  def info
    File.read('test/support/TEST_MOVIE.txt')
  end

  def rip(id)
    5.times.each do
      File.open(File.join(@tempdir, "title0#{@count}.mkv"), 'a') do |f|
        f.puts '1234567890'
      end

      sleep 2
    end
    @count += 1
  end

  def cancel
  end
end
