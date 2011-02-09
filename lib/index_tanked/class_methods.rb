module IndexTanked
  module ClassMethods
    attr_reader :tanked_fields, :index

    def index_tanked(index=nil, &block)
      @index = index || Tanked::Configuration.index
      self.instance_exec &block
    end

    def tanks(field)
      @tanked_fields << field
    end
  end
end