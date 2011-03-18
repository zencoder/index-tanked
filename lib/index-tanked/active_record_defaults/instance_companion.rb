module IndexTanked
  module ActiveRecordDefaults
    class InstanceCompanion < IndexTanked::InstanceCompanion
      def data
        field_data, other_data = *super
        field_data.merge!(:timestamp => @companion.created_at.to_i, :model => @companion.class.name)
        [field_data, other_data]
      end
    end
  end
end
