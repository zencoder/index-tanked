module IndexTanked
  class ClassCompanion
    attr_reader :fields, :variables, :texts, :doc_id_value, :index_name

    def initialize(index, klass)
      @fields = []
      @variables = []
      @texts = []
      @index_name = index || IndexTanked::Configuration.index
      @klass = klass
    end

    def doc_id(method)
      @doc_id_value = method
    end

    def field(field_name, method=field_name, options = {})
      method, options = field_name, method if method.is_a? Hash
      @fields <<  [field_name, method, options]
    end

    def text(method)
      @texts << method
    end

    def var(variable, method)
      @variables << [variable, method]
    end

    def index
      api_client.indexes @index_name
    end
    
    def api_client
      IndexTank::Client.new Configuration.url
    end

    def search_string(search_string, options={})
      [search_string, options[:fields]].compact.join(" ")
    end

  end
end