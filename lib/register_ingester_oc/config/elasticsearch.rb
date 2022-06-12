require 'elasticsearch'
require_relative 'settings'

module RegisterIngesterOc
  module Config
    ELASTICSEARCH_CLIENT = Elasticsearch::Client.new(
      host: "http://elastic:#{ENV['ELASTICSEARCH_PASSWORD']}@#{ENV['ELASTICSEARCH_HOST']}:#{ENV['ELASTICSEARCH_PORT']}",
      transport_options: { ssl: { verify: false } },
      log: false
    )
  end
end
