module IndexTanked
  module ClassMethods
    attr_reader :index_tanked_fields, :index_tanked_text, :index_tanked_index_name, :index_tanked_doc_id, :index_tanked_variables

    def index_tanked(index=nil, &block)
      @index_tanked_index_name = index || IndexTanked::Configuration.index
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

    def var(variable, method)
      @index_tanked_variables << [variable, method]
    end

    def search(search_string=nil, options={})
      api_search_result = index_tank_index.search(index_tanked_search_string(search_string, options))
      SearchResult.new(api_search_result)
    end

    def index_tank_index
      index_tank_api_client.indexes index_tanked_index_name
    end

  protected

    def index_tank_api_client
      IndexTank::Client.new Configuration.url
    end

    def index_tanked_search_string(search_string=nil, options={})
      [search_string, options[:fields]].join(" ")
    end

  end

end
