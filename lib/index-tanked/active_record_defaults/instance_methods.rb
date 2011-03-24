module IndexTanked
  module ActiveRecordDefaults
    module InstanceMethods
      def index_tanked
        @index_tanked ||= InstanceCompanion.new(self)
      end

      def add_to_index_tank
        self.class.add_to_index_tank(index_tanked.doc_id, index_tanked.data)
        ancestor = self.class._ancestors_to_index.first
        self.becomes(ancestor).add_to_index_tank if ancestor
      end
    end
  end
end
