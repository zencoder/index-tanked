module IndexTanked
  module ActiveRecordDefaults
    module InstanceMethods

      def add_to_index_tank
        doc_id = index_tanked.doc_id
        data = index_tank_data
        self.class.add_to_index_tank(doc_id, data)
      end

   protected

      def index_tank_data
        field_data, other_data = index_tanked.data
        if other_data[:variables]
          other_data[:variables].merge!(0 => id)
        else
          other_data[:variables] = {0 => id}
        end
        field_data.merge!(:timestamp => created_at.to_i)
        field_data.merge!(:model => self.class.name)

        [field_data, other_data]
      end

    end
  end
end
