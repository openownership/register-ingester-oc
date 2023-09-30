# frozen_string_literal: true

require_relative 'settings'
require 'register_sources_oc/config/elasticsearch'

module RegisterIngesterOc
  module Config
    ELASTICSEARCH_CLIENT = RegisterSourcesOc::Config::ELASTICSEARCH_CLIENT
  end
end
