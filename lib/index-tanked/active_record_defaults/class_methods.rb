module IndexTanked
  module ActiveRecordDefaults
    module ClassMethods

      def search(search_string, options={})
        ActiveRecordSearchResult.new(index_tanked_search_string(search_string), index_tank_index, self, options)
      end

    protected
      def index_tanked_search_string(search_string)
        [super, "model:#{name}"].join(" ")
      end

    end
  end
end
