module Immutable
  def new(*)
    object = super
    object.instance_variables.each do |var|
      object.instance_variable_get(var).freeze
    end
    object.freeze
  end
end
