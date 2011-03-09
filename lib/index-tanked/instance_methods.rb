module IndexTanked
  module InstanceMethods

    def add_to_index_tank
       index_tanked.index.document(index_tanked.doc_id).add(*index_tanked.data) if IndexTanked::Configuration.available?
    end

    def index_tanked
      @index_tanked ||= IndexTanked::InstanceCompanion.new(self)
    end

  end
end
