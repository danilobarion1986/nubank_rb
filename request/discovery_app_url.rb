# frozen_string_literal: true

require_relative './client'

module Request
  # Get URL's from Nubank's APP discovery endpoint
  class DiscoveryAppUrl
    URL = 'https://prod-s0-webapp-proxy.nubank.com.br/api/app/discovery'

    # Get all APP URL's available.
    #
    # @response [Hash<Symbol, String>] URL's available
    def self.call
      Request::Client.call(URL, :get)
    end
  end
end
