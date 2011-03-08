module IndexTanked
  module InstanceMethods

    def add_to_index_tank
      index_tank_index.document(index_tank_doc_id).add(*index_tank_data)
    end

    def index_tanked
      @index_tanked ||= IndexTanked::InstanceCompanion.new(self)
    end

  end
end
