require 'faraday_middleware'
require 'uri'

require "index-tanked/indextank/client"

module IndexTanked
  module IndexTank
    VERSION = "1.0.13"

    def self.setup_connection(url)
      @conn = Faraday::Connection.new(:url => url) do |builder|
        builder.use FaradayMiddleware::ParseJson
        yield builder if block_given?
        builder.adapter Faraday.default_adapter
      end
      @uri = URI.parse(url)
      @conn.basic_auth @uri.user,@uri.password
      @conn.headers['User-Agent'] = "IndexTank-Ruby/#{VERSION}"
      @conn
    end
  end
end
