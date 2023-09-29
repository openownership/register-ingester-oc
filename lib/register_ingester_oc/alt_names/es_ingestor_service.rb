# frozen_string_literal: true

require 'register_ingester_oc/services/es_ingestor_service'
require 'register_sources_oc/repositories/alt_name_repository'
require 'register_ingester_oc/alt_names/row_processor'

module RegisterIngesterOc
  module AltNames
    class EsIngestorService < Services::EsIngestorService
      def initialize(
        row_processor: AltNames::RowProcessor.new,
        repository: RegisterSourcesOc::Repositories::AltNameRepository.new(client: Config::ELASTICSEARCH_CLIENT),
        s3_adapter: Config::Adapters::S3_ADAPTER,
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET'),
        full_s3_prefix: ENV.fetch('ALT_NAMES_EXPORT_JSON_FULL_S3_PREFIX')
      )
        super
      end
    end
  end
end
