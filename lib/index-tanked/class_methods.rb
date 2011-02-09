module IndexTanked
  module ClassMethods
    attr_reader :tanked_fields, :index

    def index_tanked(index=nil, &block)
      @index = index || IndexTanked::Configuration.index
      self.instance_exec &block
    end

    def tanks(field, method=nil)
      @tanked_fields <<  [field, method]
    end
  end
end
