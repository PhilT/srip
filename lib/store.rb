module Store
  module_function

  def files_in_dir(pattern)
    Dir[pattern]
  end

  def move(from, to)
    FileUtils.mv(from, to)
  end
end

