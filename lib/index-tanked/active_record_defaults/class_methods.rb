module IndexTanked
  module ActiveRecordDefaults
    module ClassMethods

      def search_index_tank(search_string, options={})
        SearchResult.new(index_tanked_search_string(search_string), @index_tanked.index, self, options)
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
