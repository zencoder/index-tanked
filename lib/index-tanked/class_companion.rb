module IndexTanked
  class ClassCompanion
    attr_reader :fields, :variables, :texts, :index_name, :index_tank_url, :doc_id_value

    def initialize(options={})
      @fields         = []
      @variables      = []
      @texts          = []
      @index_name     = options[:index] || IndexTanked::Configuration.index
      @index_tank_url = options[:url] || IndexTanked::Configuration.url
      raise IndexTanked::URLNotProvidedError if @index_tank_url.nil? && (IndexTanked::Configuration.index_available? || IndexTanked::Configuration.search_available?)
      raise IndexTanked::IndexNameNotProvidedError if @index_name.nil? && (IndexTanked::Configuration.index_available? || IndexTanked::Configuration.search_available?)
    end

    def doc_id(method)
      @doc_id_value = method
    end

    def field(field_name, method=field_name, options={})
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
      return nil if @index_name.nil? || api_client.nil?
      api_client.indexes @index_name
    end

    def api_client
      return nil if @index_tank_url.nil?
      @api_client ||= (IndexTanked::IndexTank::Client.new @index_tank_url)
    end

    def get_value_from(instance, method)
      case method
      when Symbol
        instance.send method
      when Proc
        method.call(instance)
      else
        method
      end
    end

    def add_fields_to_query(query, options={})
      return nil if query.blank?
      [query, options[:fields] && options[:fields].to_a.map {|pair| pair.join(':')}.join(' ')].compact.join(" ").strip
    end

  end
end
