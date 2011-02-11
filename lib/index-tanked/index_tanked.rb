module IndexTanked

  def self.included(klass)
    klass.instance_variable_set(:@index_tanked_fields, [])
    klass.instance_variable_set(:@index_tanked_text, [])
    klass.extend ClassMethods
  end

  def add_to_index_tank
    field_data = {}

    text_values = self.class.index_tanked_text.map { |method| get_value_from_method_or_proc method }

    self.class.index_tanked_fields.each do |(field, method, options)|
      field_data[field] = get_value_from_method_or_proc method
      text_value = options.has_key?(:text) ? get_value_from_method_or_proc(options[:text]) : field_data[field]
      text_values << text_value
    end

    field_data.merge!(:text => text_values.compact.uniq.join(" "))

    field_data.merge!(:model => self.class.name)
    field_data.merge!(:timestamp => created_at.to_i)

    index_tank_index.document(index_tank_doc_id).add(field_data)
  end

  def index_tank_doc_id
    get_value_from_method_or_proc(self.class.index_tanked_doc_id) || "#{self.class.name}: #{id}"
  end

protected

  def index_tank_api_client
    @index_tank_api_client ||= IndexTank::Client.new Configuration.url
  end

  def index_tank_index
    @index_tank_index ||= index_tank_api_client.indexes self.class.index_tanked_index
  end

  def get_value_from_method_or_proc(method)
    case method
    when Symbol
      self.send method
    when Proc
      method.call(self)
    end
  end

end
