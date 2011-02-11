module IndexTanked
  module ClassMethods
    attr_reader :index_tanked_fields, :index_tanked_text, :index_tanked_index, :index_tanked_doc_id

    def index_tanked(index=nil, &block)
      @index_tanked_index = index || IndexTanked::Configuration.index
      self.instance_exec &block
    end

    def doc_id(method)
      @index_tanked_doc_id = method
    end

    def field(field_name, method=field_name, options = {})
      method, options = field_name, method if method.is_a? Hash
      @index_tanked_fields <<  [field_name, method, options]
    end

    def text(method)
      @index_tanked_text << method
    end
  end

end
