module IndexTanked

  class Configuration

    class << self
      attr_accessor :url, :index, :search_availability, :index_availability

      def search_available?
        if search_availability.is_a? Proc
          search_availability.call
        else
          search_availability
        end
      end

      def index_available?
        if index_availability.is_a? Proc
          index_availability.call
        else
          index_availability
        end

      end
    end

  end
end
