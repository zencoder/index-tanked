module IndexTanked

  module ActiveRecordDefaults

    def index_tank_data
      super.merge!(:timestamp => created_at.to_i)
    end

    def index_tank_doc_id
      super || "#{self.class.name}:#{id}"
    end

  end

end
