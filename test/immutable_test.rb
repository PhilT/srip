require 'minitest/autorun'
require './lib/immutable'

class ImmutableClass
  extend Immutable
  attr_accessor :immutable_var
end

class ImmutableTest < Minitest::Test
  def test_new_freezes_object
    subject = ImmutableClass.new
    assert_raises { subject.immutable_var = 'something' }
  end
end
