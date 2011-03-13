module IndexTanked
  module InstanceMethods

    def add_to_index_tank
      doc_id = index_tanked.doc_id
      data = index_tanked.data
      self.class.add_to_index_tank(doc_id, data)
    end

    def index_tanked
      @index_tanked ||= IndexTanked::InstanceCompanion.new(self)
    end

  end
end
