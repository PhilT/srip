class Ripper
  def initialize(tempdir, minlength)
    @tempdir = tempdir
    @minlength = minlength
  end

  def info
    call('info', nil)
  end

  def rip(id)
    call('mkv', id)
  end

  private

  def call(command, id = nil)
    dest = @tempdir if command == 'mkv'
    cmdline = "makemkvcon --robot --minlength=#{@minlength} #{command} disc:0 #{id} #{dest}".strip
    output = cmdline + "\n" + `#{cmdline}`

    File.open(File.join(@tempdir, 'ripper.log'), 'a') do |f|
      f.puts output
    end
    output
  end
end
