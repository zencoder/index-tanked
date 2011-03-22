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

      def dependent_fields
        if !@dependent_fields
          @dependent_fields = @fields.map do |field|
            field[2][:depends_on] || field[1]
          end.flatten.compact.uniq

          if !@dependent_fields.include?(:created_at) && model.column_names.include?("created_at")
            @dependent_fields << :created_at
          end
        end

        @dependent_fields
      end

      def dependent_fields_as_strings
        @dependent_fields_as_strings ||= dependent_fields.map(&:to_s)
      end

      def dependent_fields_for_select(*additional_fields)
        fields = if additional_fields.empty?
          dependent_fields_as_strings
        else
          (dependent_fields_as_strings + additional_fields.map(&:to_s)).uniq
        end
        fields.join(', ')
      end

      def retry_on_error(options={})
        times            = options[:times] || 3
        delay_multiplier = options[:delay_multiplier] || 0
        excepts          = [options[:except]].compact.flatten
        count            = 0
        begin
          yield
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

      def field(field_name, method=field_name, options={})
        super

        field = @fields.last
        method = field[1]
        method_without_sugar = method.to_s.sub(/[\?=]$/, '')
        options = field[2]

        if options[:depends_on].nil? || (options[:depends_on].is_a?(Array) && options[:depends_on].empty?)
          case method
          when Symbol
            if !model.column_names.include?(method_without_sugar)
              raise MissingFieldDependencyError, "The #{field_name} field requires a dependency to be specified"
            end
          when Proc
            raise MissingFieldDependencyError, "The #{field_name} field requires a dependency to be specified"
          end
        end

        dependencies = [options[:depends_on] || method_without_sugar].flatten.compact.map(&:to_s)
        invalid_dependencies = dependencies - model.column_names

        if !invalid_dependencies.empty?
          raise InvalidFieldDependencyError, "The following field dependencies are invalid: #{invalid_dependencies.join(', ')}"
        end

        @fields
      end

    end
  end
end
