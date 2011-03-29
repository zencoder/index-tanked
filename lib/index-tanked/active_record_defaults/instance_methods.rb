module IndexTanked
  module ActiveRecordDefaults
    module InstanceMethods
      def index_tanked
        @index_tanked ||= InstanceCompanion.new(self)
      end

      def add_to_index_tank(fallback=true)
        self.class.add_to_index_tank(index_tanked.doc_id, index_tanked.data, fallback)
        ancestor = self.class._ancestors_to_index.first
        self.becomes(ancestor).add_to_index_tank(fallback) if ancestor
      end

      def add_to_index_tank_after_save(fallback=true)
        if index_tanked.dependencies_changed?
          add_to_index_tank(fallback)
        end
      end

      def delete_from_index_tank_after_destroy
        doc_ids = []
        doc_ids << index_tanked.doc_id
        self.class._ancestors_to_index.each do |ancestor|
          doc_ids << becomes(ancestor).index_tanked.doc_id
        end
        self.class.delete_doc_ids_from_index_tank(doc_ids.compact)
      end
    end
  end
end
