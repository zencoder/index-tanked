module IndexTanked

  module ActiveRecordDefaults

    module InstanceMethods

      def index_tank_data
        field_data, other_data = *super
        if other_data[:variables]
          other_data[:variables].merge!(0 => id)
        else
          other_data[:variables] = {0 => id}
        end
        field_data.merge!(:timestamp => created_at.to_i)
        field_data.merge!(:model => self.class.name)

        [field_data, other_data]
      end

      def index_tank_doc_id
        super || "#{self.class.name}:#{id}"
      end

    end

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
