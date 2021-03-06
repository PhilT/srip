class Ripper
  def info(tempdir, minlength)
    call('info', tempdir, nil, minlength)
  end

  def rip(tempdir, id, minlength)
    call('mkv', tempdir, id, minlength)
  end

  private

  def call(command, tempdir, id = nil, minlength = 1800)
    dest = tempdir if command == 'mkv'
    cmdline = "makemkvcon --robot --minlength=#{minlength} #{command} disc:0 #{id} #{dest}".strip
    output = cmdline + "\n" + `#{cmdline}`

    File.open(File.join(tempdir, 'ripper.log'), 'a') do |f|
      f.puts output
    end
    output
  end
end
