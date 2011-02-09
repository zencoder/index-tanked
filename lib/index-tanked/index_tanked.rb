module IndexTanked

  def self.included(klass)
    klass.instance_variable_set(:@tanked_fields, [])
    klass.extend ClassMethods
  end

  def add_to_index_tank
    data = self.class.tanked_fields.inject({}) do |data, (field, method)|
      data[field] = method ? method.call(self) : send(field)
      data
    end
    data.merge!(:text => data.values.join(" "))
    data.merge!(:model => self.class.name)
    data.merge!(:timestamp => created_at.to_i)

    index_tank_index.document("#{self.class.name}: #{id}").add(data)
  end

protected

  def index_tank_api_client
    @index_tank_api_client ||= IndexTank::Client.new Configuration.url
  end

  def index_tank_index
    @index_tank_index ||= index_tank_api_client.indexes self.class.index
  end

end
