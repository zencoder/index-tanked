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
        WillPaginate::Collection.create(@page, @per_page) do |pager|
          records = @model.find(ids, options)
          pager.replace(records)
          pager.total_entries = results.total_entries unless pager.total_entries
        end
      end
      
    end
  end
end