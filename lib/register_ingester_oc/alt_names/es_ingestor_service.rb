# frozen_string_literal: true

require 'register_sources_oc/repository'

require_relative '../services/es_ingestor_service'
require_relative 'row_processor'

module RegisterIngesterOc
  module AltNames
    class EsIngestorService < Services::EsIngestorService
      def initialize(
        row_processor: AltNames::RowProcessor.new,
        repository: RegisterSourcesOc::Repository.new(
          RegisterSourcesOc::AltName,
          client: Config::ELASTICSEARCH_CLIENT,
          index: RegisterSourcesOc::Config::ELASTICSEARCH_INDEX_ALT_NAMES
        ),
        s3_adapter: Config::Adapters::S3_ADAPTER,
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET'),
        full_s3_prefix: ENV.fetch('ALT_NAMES_EXPORT_JSON_FULL_S3_PREFIX')
      )
        super
      end
    end
  end
end
