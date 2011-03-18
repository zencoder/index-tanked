module IndexTanked

  class CustomDocIdNotSupportedError < IndexTankedError; end

  module ActiveRecordDefaults
    class ClassCompanion < IndexTanked::ClassCompanion

      attr_reader :model

      def initialize(model, options)
        @model = model
        super(options)
      end

      def add_fields_to_query(query, options={})
        [super, "model:#{@model.name}"].compact.join(" ")
      end

      def doc_id
        raise CustomDocIdNotSupportedError
      end

      def doc_id_value
        lambda { |instance| "#{instance.class.name}:#{instance.id}"}
      end

    end
  end
end
