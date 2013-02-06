module IndexTanked
  class SearchResult

    attr_reader :page, :per_page

    def initialize(query, index, options={})
      @index   = index
      @options = options
      @query   = query
    end

    def search_time(force=false)
      execute_search(force)
      @raw_result['search_time']
    end

    def facets(force=false)
      execute_search(force)
      @raw_result["facets"]
    end

    def matches(force=false)
      execute_search(force)
      @raw_result["matches"]
    end

    def results(force=false)
      execute_search(force)
      @results
    end

    def raw_result(force=false)
      execute_search(force)
      @raw_result
    end


  protected

    def execute_search(force=false)
      @results = @raw_result = nil if force

      @page ||= @options.delete(:page) || 1
      @per_page ||= @options.delete(:per_page) || 15

      @results ||= WillPaginate::Collection.create(@page, @per_page) do |pager|
        begin
          raise SearchingDisabledError, "index tank search is disabled in configuration" unless IndexTanked::Configuration.search_available?
          raise IndexTanked::SearchError, "No or invalid index has been provided" unless @index.is_a? IndexTanked::IndexTank::Index
          raise IndexTanked::SearchError, "No query provided" if @query.nil?
          search_timeout = if IndexTanked::Configuration.search_timeout.is_a?(Proc)
            IndexTanked::Configuration.search_timeout.call
          else
            IndexTanked::Configuration.search_timeout
          end
          if search_timeout
            IndexTanked::Timer.timeout(search_timeout, TimeoutExceededError) do
              sleep(search_timeout + 1) if $testing_index_tanked_search_timeout
              @raw_result ||= @index.search(@query, @options.merge(:start => pager.offset, :len => pager.per_page))
            end
          else
            @raw_result ||= @index.search(@query, @options.merge(:start => pager.offset, :len => pager.per_page))
          end
        rescue StandardError => e
          raise if e.is_a? IndexTankedError
          raise IndexTanked::SearchError, "#{e.class}: #{e.message}"
        end
        pager.replace(@raw_result['results'])
        pager.total_entries = @raw_result["matches"] unless pager.total_entries
      end
    end

  end
end
