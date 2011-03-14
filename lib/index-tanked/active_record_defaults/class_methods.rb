module IndexTanked
  module ActiveRecordDefaults
    module ClassMethods

      def search_index_tank(search_string, options={})
        SearchResult.new(index_tanked_search_string(search_string), @index_tanked.index, self, options)
      end

    protected
      def index_tanked_search_string(search_string)
        [super, "model:#{name}"].compact.join(" ")
      end

    end
  end
end
