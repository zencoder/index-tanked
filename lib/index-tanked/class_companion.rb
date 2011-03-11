module IndexTanked
  class ClassCompanion
    attr_reader :fields, :variables, :texts, :doc_id_value, :index_name

    def initialize(index)
      @fields = []
      @variables = []
      @texts = []
      @index_name = index || IndexTanked::Configuration.index
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
      return if api_client.nil?
      api_client.indexes @index_name
    end

    def api_client
      @api_client ||= (IndexTank::Client.new IndexTanked::Configuration.url) if IndexTanked::Configuration.index_available?
    end

  end
end