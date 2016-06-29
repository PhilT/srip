class Ripper
  def initialize(tempdir, minlength)
    @tempdir = tempdir
    @minlength = minlength
  end

  def label
    label = nil
    3.times do
      label = exec_command('blkid /dev/sr0').match(/LABEL="(.*?)"/).to_a[1]
      break if label
      sleep 3
    end
    label || ''
  end

  def info
    makemkv('info', nil)
  end

  def rip(id)
    makemkv('mkv', id)
  end

  def cancel
    puts "Aborting #{@pid}"
    Process.kill('HUP', @pid) if @pid
    Process.wait(@pid)
    puts "Aborted #{@pid}"
    @pid = nil
  end

  private

  def makemkv(command, id = nil)
    dest = @tempdir if command == 'mkv'
    cmdline = "makemkvcon --robot --minlength=#{@minlength} #{command} disc:0 #{id} #{dest}".strip
    output = "#{cmdline}\n#{exec_command(cmdline)}"

    File.open(File.join(@tempdir, 'ripper.log'), 'a') do |f|
      f.puts output
    end
    output
  end

  def exec_command(cmdline)
    puts "Executing #{cmdline}"
    io = IO.popen(cmdline)
    @pid = io.pid
    puts "Waiting on #{@pid} from #{cmdline}"
    Process.wait(@pid)
    @pid = nil
    puts "Finished #{cmdline}"
    io.read
  end
end
