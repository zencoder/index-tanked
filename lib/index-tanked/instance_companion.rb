module IndexTanked
  class InstanceCompanion

    def initialize(companion)
      @companion = companion
    end

    def data
      field_data = {}
      other_data = {}

      text_values = @companion.class.index_tanked.texts.map { |method| @companion.class.index_tanked.get_value_from(@companion, method) }

      @companion.class.index_tanked.fields.each do |(field, method, options)|
        value = @companion.class.index_tanked.get_value_from(@companion, method)
        unless value.nil?
          field_data[field] = value
          text_values << (options.has_key?(:text) ? @companion.class.index_tanked.get_value_from(@companion, options[:text]) : field_data[field])
        end
      end

      field_data.merge!(:text => text_values.compact.uniq.join(" "))

      variables = @companion.class.index_tanked.variables.inject({}) do |variables, (variable, method)|
        variables[variable] = @companion.class.index_tanked.get_value_from(@companion, method)
        variables
      end

      other_data[:variables] = variables unless variables.empty?

      [field_data, other_data]

    end

    def doc_id
      @companion.class.index_tanked.get_value_from(@companion, @companion.class.index_tanked.doc_id_value)
    end

    def api_client
      @index_tank_api_client ||= @companion.class.index_tanked.api_client
    end

    def index
      @index_tank_index ||= @companion.class.index_tanked.index
    end

  end
end
