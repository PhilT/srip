require 'optparse'

class Options
  def initialize
    @options = {
      tempdir: '/media/tmp',
      library: '/media/Rented'
    }
  end

  def parse
    OptionParser.new do |opts|
      opts.banner = 'Usage: rip [options]'

      opts.on('--tempdir=DIR', 'Folder to rip to before moving to library (default: /media)') do |value|
        @options[:tempdir] = value
      end

      opts.on('--library=DIR', 'Folder to move file(s) to once ripped (default: /media/Rented)') do |value|
        @options[:library] = value
      end

      opts.on('--year=YEAR', 'Release year (prompts if not supplied for movies)') do |value|
        @options[:year] = value
      end

      opts.on('--minlength=LENGTH', 'Igore titles less than this length (default: 30 (minutes))') do |value|
        @options[:minlength] = value.to_i * 60 || 1800
      end

      opts.on('--silent', 'Do not confirm before starting rip') do
        @options[:silent] = true
      end

      opts.on('--norip', 'Just get the info. Do not actually rip') do
        @options[:norip] = true
      end

      opts.on('--help', 'Prints this help') do
        puts opts
        exit
      end
    end.parse!

    @options
  end
end
