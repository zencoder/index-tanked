module IndexTanked

  module ActiveRecordDefaults

    module InstanceMethods

      def index_tank_data
        field_data = super
        if field_data[:variables]
          field_data[:variables].merge!(0 => id)
        else
          field_data[:variables] = {0 => id}
        end
        field_data.merge!(:timestamp => created_at.to_i)
        field_data.merge!(:model => self.class.name)
      end

      def index_tank_doc_id
        super || "#{self.class.name}:#{id}"
      end

    end

    module ClassMethods

      def search(search_string=nil, options={})
        api_search_result = index_tank_index.search(index_tanked_search_string(search_string), options)
        ActiveRecordSearchResult.new(api_search_result, self)
      end

    protected
      def index_tanked_search_string(search_string=nil)
        [super, "model:#{name}"].join(" ")
      end
    end

  end

end
