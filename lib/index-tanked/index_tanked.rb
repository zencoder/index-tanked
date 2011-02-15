module IndexTanked

  def self.included(base)
    base.instance_variable_set(:@index_tanked_fields, [])
    base.instance_variable_set(:@index_tanked_variables, [])
    base.instance_variable_set(:@index_tanked_text, [])
    base.class_eval do
      extend ClassMethods
      if defined?(ActiveRecord::Base) && ancestors.include?(ActiveRecord::Base)
        include ActiveRecordDefaults::InstanceMethods
        extend ActiveRecordDefaults::ClassMethods
      end
    end
  end

  def add_to_index_tank
    index_tank_index.document(index_tank_doc_id).add(*index_tank_data)
  end

  def index_tank_data
    field_data = {}
    other_data = {}

    text_values = self.class.index_tanked_text.map { |method| get_value_from method }

    self.class.index_tanked_fields.each do |(field, method, options)|
      field_data[field] = get_value_from method
      text_values << (options.has_key?(:text) ? get_value_from(options[:text]) : field_data[field])
    end

    field_data.merge!(:text => text_values.compact.uniq.join(" "))

    variables = self.class.index_tanked_variables.inject({}) do |variables, (variable, method)|
      variables[variable] = get_value_from method
      variables
    end

    other_data[:variables] = variables unless variables.empty?

    [field_data, other_data]

  end

  def index_tank_doc_id
    get_value_from(self.class.index_tanked_doc_id) || "#{self.class.name}:#{id}"
  end

protected

  def index_tank_api_client
    @index_tank_api_client ||= self.class.index_tanked_api_client
  end

  def index_tank_index
    @index_tank_index ||= self.class.index_tank_index
  end

  def get_value_from(method)
    case method
    when Symbol
      self.send method
    when Proc
      method.call(self)
    else
      method
    end
  end

end
