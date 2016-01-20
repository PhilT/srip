module StringUtil
  module_function

  def titleize(str)
    str.split(/_| /).map {|part| part[0..0].upcase + part[1..-1].downcase }.join(' ')
  end
end

