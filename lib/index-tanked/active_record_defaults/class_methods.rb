module IndexTanked
  module ActiveRecordDefaults
    module ClassMethods

      def index_tank(options={}, &block)
        @index_tanked ||= ClassCompanion.new(self, options)
        @index_tanked.instance_exec &block
      end

      def search_index_tank(query, options={})
        SearchResult.new(index_tanked.add_fields_to_query(query), @index_tanked.index, self, options)
      end

      def doc_id_value
        @doc_id_value || proc { |instance| "#{instance.class.name}:#{instance.id}"}
      end

    protected
      def index_tanked_search_string(search_string)
        [super, "model:#{name}"].compact.join(" ")
      end

    end
  end
end
