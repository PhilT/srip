class Ripper
  def initialize(tempdir, minlength)
    @tempdir = tempdir
    @minlength = minlength
  end

  def label
    @label = nil
    3.times do
      @label = exec_command('blkid /dev/sr0').match(/LABEL="(.*?)"/).to_a[1]
      break if @label
      sleep 3
    end
    @label || ''
  end

  def info
    makemkv('info', nil)
  end

  def rip(id)
    makemkv('mkv', id)
  end

  def cancel
    return unless @pid
    Process.kill('HUP', @pid)
    Process.wait(@pid)
    @pid = nil
  end

  private

  def write_log(output, type)
    path = File.join(LOG_PATH, "#{@label}_#{type}.txt")
    File.write(path, output)
  end

  def makemkv(command, id = nil)
    dest = @tempdir if command == 'mkv'
    cmdline = "makemkvcon --robot --minlength=#{@minlength} #{command} disc:0 #{id} #{dest}".strip
    output = "#{cmdline}\n#{exec_command(cmdline)}"
    write_log(output, command)
    output
  end

  def exec_command(cmdline)
    data = IO.popen(cmdline) do |io|
      @pid = io.pid
      io.read
    end
    @pid = nil
    data
  end
end
