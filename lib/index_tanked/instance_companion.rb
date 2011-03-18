module IndexTanked
  class InstanceCompanion

    def initialize(companion)
      @companion = companion
      @index_tanked = companion.class.index_tanked
    end

    def data
      field_data = {}
      other_data = {}

      text_values = @index_tanked.texts.map { |method| @index_tanked.get_value_from(@companion, method) }

      @index_tanked.fields.each do |(field, method, options)|
        value = @index_tanked.get_value_from(@companion, method)
        unless value.nil?
          field_data[field] = value
          text_values << (options.has_key?(:text) ? @index_tanked.get_value_from(@companion, options[:text]) : field_data[field])
        end
      end

      field_data.merge!(:text => text_values.compact.uniq.join(" "))

      variables = @index_tanked.variables.inject({}) do |variables, (variable, method)|
        variables[variable] = @index_tanked.get_value_from(@companion, method)
        variables
      end

      other_data[:variables] = variables unless variables.empty?

      [field_data, other_data]
    end

    def document_for_batch_addition
      fields, document = *data
      document.merge!(:docid => doc_id)
      document.merge!(:fields => fields)
      document
    end

    def doc_id
      @index_tanked.get_value_from(@companion, @index_tanked.doc_id_value)
    end

    def api_client
      @index_tanked.api_client
    end

    def index
      @index_tanked.index
    end

  end
end
