module IndexTanked
  module ActiveRecordDefaults
    class SearchResult < SearchResult

      attr_reader :model, :missing_ids

      def initialize(query, index, model, options={})
        super(query, index, options)
        @model = model
      end

      def ids
        results.map { |result| id = result['docid'].match(/^#{@model.name}:(\d+)$/); id && id[1].to_i }.compact.uniq
      end

      def records(options={})
        base = @model
        if defined?(Squirrel) && base.respond_to?(:scoped_without_squirrel)
          base = base.scoped_without_squirrel(:conditions => {:id => ids})
        else
          base = base.scoped(:conditions => {:id => ids})
        end
        records_found = base.all(options)
        @missing_ids = ids - records_found.map(&:id)
        begin
          if Configuration.missing_activerecord_ids_handler
            Configuration.missing_activerecord_ids_handler.call(@model.name, @missing_ids)
          end
        ensure
          return records_found
        end
      end

      def paginate(options={})
        original_options = options.clone

        @options[:page]     = options.delete(:page) || 1
        @options[:per_page] = options.delete(:per_page) || 15

        begin
          WillPaginate::Collection.create(@options[:page], @options[:per_page]) do |pager|
            pager.replace(records(options))
            pager.total_entries = results.total_entries unless pager.total_entries
          end
        rescue IndexTankedError
          @model.paginate(original_options)
        end
      end

      def inspect
        "<IndexTanked::ActiveRecordDefaults::SearchResult:#{object_id}, Query:'#{@query}'>"
      end

    end
  end
end
