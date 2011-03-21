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

      def retry_on_error(options={}, &block)
        times            = options[:times] || 3
        delay_multiplier = options[:delay_multiplier] || 0
        excepts          = [options[:except]].compact.flatten
        count            = 0
        begin
          instance_eval(&block)
        rescue Timeout::Error, StandardError => e
          if excepts.include?(e.class)
            raise e
          else
            retry if times == :infinity
            count += 1
            sleep count * delay_multiplier
            retry if count < times
            raise e
          end
        end
      end

    end
  end
end
