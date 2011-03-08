module IndexTanked

  class SearchError < StandardError; end

  def self.included(base)
    base.class_eval do
      include IndexTanked::InstanceMethods
      extend IndexTanked::ClassMethods
      if defined?(ActiveRecord::Base) && ancestors.include?(ActiveRecord::Base)
        include ActiveRecordDefaults::InstanceMethods
        extend ActiveRecordDefaults::ClassMethods
      end
    end
  end
end