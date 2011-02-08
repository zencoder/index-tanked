module Tanked

  module Base

    def index_tank_info
      "#{Tanked::Configuration.index} @ #{Tanked::Configuration.url}"
    end

  end

end
