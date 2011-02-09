module IndexTanked

  def self.included(klass)
    klass.instance_variable_set(:@tanked_fields, [])
    klass.extend ClassMethods
  end

end
