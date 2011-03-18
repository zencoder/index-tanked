module IndexTanked

  class IndexTankedError < StandardError; end
  class SearchError < IndexTankedError; end
  class SearchingDisabledError < IndexTankedError; end
  class IndexingDisabledError < IndexTankedError; end
  class URLNotProvidedError < IndexTankedError; end
  class IndexNameNotProvidedError < IndexTankedError; end
  class TimeoutExceededError < IndexTankedError; end

  def self.included(base)
    base.class_eval do
      include IndexTanked::InstanceMethods
      extend IndexTanked::ClassMethods

      if defined?(ActiveRecord::Base) && ancestors.include?(ActiveRecord::Base)
        include ActiveRecordDefaults::InstanceMethods
        extend ActiveRecordDefaults::ClassMethods

        class << self
          attr_accessor :_ancestors_to_index
        end

        self._ancestors_to_index = ancestors.select{|a|
          a != self && a != ActiveRecord::Base && a.ancestors.include?(ActiveRecord::Base) && !a.abstract_class?
        }

        after_save do |instance|
          instance.add_to_index_tank
          instance.class._ancestors_to_index.each do |ancestor|
            instance.becomes(ancestor).add_to_index_tank
          end
        end

        after_destroy do |instance|
          doc_id = instance.index_tanked.doc_id
          instance.class.delete_from_index_tank(doc_id)
          instance.class._ancestors_to_index.each do |ancestor|
            doc_id = instance.index_tanked.doc_id
            instance.becomes(ancestor).delete_from_index_tank(doc_id)
          end
        end
      end
    end
  end
end
