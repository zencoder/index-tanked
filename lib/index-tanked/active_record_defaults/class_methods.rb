module IndexTanked
  module ActiveRecordDefaults
    module ClassMethods

      def index_tank(options={}, &block)
        @index_tanked ||= ClassCompanion.new(self, options)
        @index_tanked.instance_exec &block
      end

      # pass in scoped with an empty hash to give the search result a representation of the current scope
      def search_index_tank(query, options={})
        SearchResult.new(index_tanked.add_fields_to_query(query, options), @index_tanked.index, scoped({}), options)
      end

      def add_all_to_index_tank(options={})
        options[:batch_size] ||= 50
        count = 0
        find_in_batches(options) do |instances|
          documents = instances.map { |instance| instance.index_tanked.document_for_batch_addition }
          documents = documents.flatten.compact
          count += documents.size
          index_tanked.retry_on_error(:times => 5, :delay_multiplier => 2) do
            index_tanked.index.batch_insert(documents)
          end
        end
        count
      end

    end
  end
end
