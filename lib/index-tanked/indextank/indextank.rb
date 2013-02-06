require 'faraday_middleware'
require 'faraday_middleware/response_middleware'
require 'uri'

require 'index-tanked/indextank/client'

module IndexTanked
  module IndexTank
    VERSION = "1.0.12"

    def self.setup_connection(url)
      ## in Faraday 0.8 or above:
      @conn = Faraday.new(url) do |conn|
        conn.response :json
        yield conn if block_given?
        conn.adapter Faraday.default_adapter
      end
      @uri = URI.parse(url)
      @conn.basic_auth @uri.user,@uri.password
      @conn.headers['User-Agent'] = "IndexTanked::IndexTank-Ruby/#{VERSION}"
      @conn
    end
  end
end
