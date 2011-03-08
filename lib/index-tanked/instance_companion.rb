module IndexTanked
  class InstanceCompanion

    def initialize(companion)
      @companion = companion
    end

    def data
      field_data = {}
      other_data = {}

      text_values = @companion.class.index_tanked.texts.map { |method| get_value_from method }

      @companion.class.index_tanked.fields.each do |(field, method, options)|
        field_data[field] = get_value_from method
        text_values << (options.has_key?(:text) ? get_value_from(options[:text]) : field_data[field])
      end

      field_data.merge!(:text => text_values.compact.uniq.join(" "))

      variables = @companion.class.index_tanked.variables.inject({}) do |variables, (variable, method)|
        variables[variable] = get_value_from method
        variables
      end

      other_data[:variables] = variables unless variables.empty?

      [field_data, other_data]

    end

    def doc_id
      get_value_from(@companion.class.index_tanked.doc_id_value) || "#{@companion.class.name}:#{id}"
    end

    def api_client
      @index_tank_api_client ||= @companion.class.index_tanked_api_client
    end

    def index
      @index_tank_index ||= @companion.class.index_tank_index
    end

    def get_value_from(method)
      case method
      when Symbol
        @companion.send method
      when Proc
        method.call(@companion)
      else
        method
      end
    end

  end
end
