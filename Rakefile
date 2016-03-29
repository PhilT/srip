require 'listen'

task :default => :test
task :test do
	Dir.glob('./test/*_test.rb').each { |file| require file}
end

task :watch do
  listener = Listen.to('lib', 'test') do
    system 'rake'
  end
  listener.start # not blocking
  sleep
end
