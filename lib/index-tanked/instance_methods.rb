module IndexTanked
  module InstanceMethods

    def add_to_index_tank
      self.class.add_to_index_tank(index_tanked.doc_id, index_tanked.data)
    end

    def index_tanked
      @index_tanked ||= IndexTanked::InstanceCompanion.new(self)
    end

  end
end
