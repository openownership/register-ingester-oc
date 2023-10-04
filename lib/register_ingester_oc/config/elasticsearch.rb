# frozen_string_literal: true

require 'register_sources_oc/config/elasticsearch'

require_relative 'settings'

module RegisterIngesterOc
  module Config
    ELASTICSEARCH_CLIENT = RegisterSourcesOc::Config::ELASTICSEARCH_CLIENT
  end
end
