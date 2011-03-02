module IndexTanked

  class SearchResult

    attr_reader :raw_result, :results, :page, :per_page

    def initialize(search_string, index, options={})
      @page = options.delete(:page) || 1
      @per_page = options.delete(:per_page) || 10

      @results ||= WillPaginate::Collection.create(@page, @per_page) do |pager|
        @raw_result = index.search(search_string, options.merge(:start => pager.offset, :len => pager.per_page))
        pager.replace(@raw_result['results'])
        pager.total_entries = @raw_result["matches"] unless pager.total_entries
      end
    end

    def search_time
      @raw_result['search_time']
    end

    def facets
      @raw_result["facets"]
    end

  end

end
