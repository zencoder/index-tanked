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
  end
end
