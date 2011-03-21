module IndexTanked
  module ActiveRecordDefaults
    class InstanceCompanion < IndexTanked::InstanceCompanion
      if defined?(ActiveRecord::MissingAttributeError)
        MissingAttributeError = ActiveRecord::MissingAttributeError
      else
        MissingAttributeError = ActiveModel::MissingAttributeError
      end

      def data
        begin
          field_data, other_data = *super
          field_data.merge!(:timestamp => @companion.created_at.to_i, :model => @companion.class.name)
        rescue MissingAttributeError
          @companion.reload
          field_data, other_data = *super
          field_data.merge!(:timestamp => @companion.created_at.to_i, :model => @companion.class.name)
        end
        [field_data, other_data]
      end
    end
  end
end
