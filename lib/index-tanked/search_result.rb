module IndexTanked

  class SearchResult

    attr_reader :raw_result

    def initialize(search_result)
      @raw_result = search_result
    end

    def search_time
      @raw_result['search_time']
    end

    def matches
      @raw_result["matches"]
    end

    def facets
      @raw_result["facets"]
    end

    def results
      @raw_result["results"]
    end

  end

end