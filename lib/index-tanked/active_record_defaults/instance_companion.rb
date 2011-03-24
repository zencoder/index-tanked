module IndexTanked
  module ActiveRecordDefaults
    class InstanceCompanion < IndexTanked::InstanceCompanion
      if defined?(ActiveRecord::MissingAttributeError)
        MissingAttributeError = ActiveRecord::MissingAttributeError
      else
        MissingAttributeError = ActiveModel::MissingAttributeError
      end

      def created_at
        if @companion.respond_to?(:created_at)
          @companion.created_at
        else
          Time.now
        end
      end

      def data
        begin
          field_data, other_data = *super
          field_data.merge!(:timestamp => created_at.to_i, :model => @companion.class.name)
        rescue MissingAttributeError
          @companion.reload
          field_data, other_data = *super
          field_data.merge!(:timestamp => created_at.to_i, :model => @companion.class.name)
        end
        [field_data, other_data]
      end

      def dependencies_changed?
        @companion.class.index_tanked.dependent_fields.any?{|field| @companion.send("#{field}_changed?") }
      end

      def document_for_batch_addition
        ancestor = @companion.class._ancestors_to_index.first
        if ancestor
          documents = []
          documents << super
          documents << @companion.becomes(ancestor).index_tanked.document_for_batch_addition if ancestor
          documents.flatten.compact
        else
          super
        end
      end

    end
  end
end
