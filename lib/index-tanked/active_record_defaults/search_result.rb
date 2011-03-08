module IndexTanked
  module ActiveRecordDefaults
    class SearchResult < SearchResult

      def initialize(search_string, index, model, options={})
        super(search_string, index, options)
        @model = model
      end

      def ids
        results.map { |result| id = result['docid'].match(/^#{@model.name}:(\d+)$/); id && id[1].to_i }.compact.uniq
      end

      def records(options={})
        @model.find(ids, options)
      end

      def paginate(options={})
        original_options = options.clone

        @options[:page] = options.delete(:page)
        @options[:per_page] = options.delete(:per_page)

        begin
          WillPaginate::Collection.create(@options[:page], @options[:per_page]) do |pager|
            pager.replace(records(options))
            pager.total_entries = results.total_entries unless pager.total_entries
          end
        rescue IndexTanked::SearchError
          @model.paginate(original_options)
        end
      end

    end
  end
end
