module IndexTanked

  class IndexTankedError < StandardError; end
  class SearchError < IndexTankedError; end
  class SearchingDisabledError < IndexTankedError; end
  class IndexingDisabledError < IndexTankedError; end
  class URLNotProvidedError < IndexTankedError; end
  class IndexNameNotProvidedError < IndexTankedError; end
  class TimeoutExceededError < IndexTankedError; end
  class MissingFieldDependencyError < IndexTankedError; end
  class InvalidFieldDependencyError < IndexTankedError; end

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

        after_save :add_to_index_tank_after_save

        after_destroy :delete_from_index_tank_after_destroy
      end
    end
  end
end
