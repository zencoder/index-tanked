module IndexTanked

  class SearchResult

    attr_reader :page, :per_page

    def initialize(search_string, index, options={})
      @index = index
      @options = options
      @search_string = search_string
    end

    def search_time
      execute_search
      @raw_result['search_time']
    end

    def facets
      execute_search
      @raw_result["facets"]
    end

    def matches
      execute_search
      @raw_result["matches"]
    end

    def results
      execute_search
      @results
    end

    def raw_result
      execute_search
      @raw_result
    end

  protected

    def execute_search
      @page = @options.delete(:page) || 1
      @per_page = @options.delete(:per_page) || 15

      @results ||= WillPaginate::Collection.create(@page, @per_page) do |pager|
        begin
          @raw_result ||= @index.search(@search_string, @options.merge(:start => pager.offset, :len => pager.per_page))
        rescue StandardError => e
          raise IndexTanked::SearchError, "#{e.class}: #{e.message}"
        end
        pager.replace(@raw_result['results'])
        pager.total_entries = @raw_result["matches"] unless pager.total_entries
      end
    end

  end

end
