class Ripper
  def initialize(tempdir, minlength)
    @tempdir = tempdir
    @minlength = minlength
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

  def makemkv(command, id = nil)
    dest = @tempdir if command == 'mkv'
    cmdline = "makemkvcon --robot --minlength=#{@minlength} #{command} disc:0 #{id} #{dest}".strip
    "#{cmdline}\n#{exec_command(cmdline)}"
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
