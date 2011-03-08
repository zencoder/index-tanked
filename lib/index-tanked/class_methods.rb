module IndexTanked
  module ClassMethods
    attr_reader :index_tanked

    def index_tank(index=nil, &block)
      @index_tanked = IndexTanked::ClassCompanion.new(index, self)
      @index_tanked.instance_exec &block
    end

    def search(search_string, options={})
      SearchResult.new(index_tanked_search_string(search_string), index_tank_index, options)
    end

  end

end
