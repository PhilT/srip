class Ripper
  def info
    call('info')
  end

  def rip(tempdir, id)
    output = call('mkv', id, tempdir)
    File.open(File.join(tempdir, 'ripper.log'), 'a') do |f|
      f.puts output
    end
  end

  private

  def call(command, *options)
    cmdline = "makemkvcon --robot --minlength=1800 #{command} disc:0 #{options.join(' ')}"
    cmdline + "\n" + `#{cmdline}`
  end
end

