require 'minitest/autorun'
require './lib/store'

class StoreTest < Minitest::Test
  def setup
    FileUtils.mkdir('tmp')
  end

  def teardown
    FileUtils.rm_rf('tmp')
  end

  def subject
    Store.new
  end

  def test_files_in_dir_returns_some_files
    files = subject.files_in_dir('test/*_test.rb')
    assert_includes files, 'test/store_test.rb'
  end

  def test_move_renames_a_file
    FileUtils.touch 'tmp/file.dummy'
    subject.move('tmp/file.dummy', 'tmp/newfile.dummy')
    assert File.exists?('tmp/newfile.dummy')
    assert !File.exists?('tmp/file.dummy')
  end
end

