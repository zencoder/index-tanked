module IndexTanked

  class SearchError < StandardError; end
  class SearchingDisabledError < StandardError; end
  class IndexingDisabledError < StandardError; end

  def self.included(base)
    base.class_eval do
      include IndexTanked::InstanceMethods
      extend IndexTanked::ClassMethods
      if defined?(ActiveRecord::Base) && ancestors.include?(ActiveRecord::Base)
        include ActiveRecordDefaults::InstanceMethods
        extend ActiveRecordDefaults::ClassMethods

        after_save do |instance|
          relevant_ancestors = instance.class.ancestors.select{|a| a.ancestors.include?(ActiveRecord::Base)}
          instance.add_to_index_tank
          relevant_ancestors.each do |relevant_ancestor|
            instance.becomes(relevant_ancestor).add_to_index_tank
          end
        end

        after_destroy do |instance|
          instance.class.delete_from_index_tank(instance.id)
        end

      end
    end
  end
end