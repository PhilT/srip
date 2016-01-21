Dir['./lib/*.rb'].each do |file|
  require file
end

require "minitest/reporters"
Minitest::Reporters.use!

require 'minitest/autorun'
require 'fakefs/safe'

