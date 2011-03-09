module IndexTanked

  class Configuration

    class << self
      attr_accessor :url, :index, :availability

      def available?
        if availability.is_a? Proc
          availability.call
        else
          availability
        end
      end
    end

  end
end
