module IndexTanked
  module ActiveRecordDefaults
    module InstanceMethods
      def index_tanked
        @index_tanked ||= InstanceCompanion.new(self)
      end
    end
  end
end
