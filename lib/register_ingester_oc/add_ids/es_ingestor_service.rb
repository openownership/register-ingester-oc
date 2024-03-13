# frozen_string_literal: true

require 'register_sources_oc/repository'

require_relative '../services/es_ingestor_service'
require_relative 'row_processor'

module RegisterIngesterOc
  module AddIds
    class EsIngestorService < Services::EsIngestorService
      def initialize(
        row_processor: AddIds::RowProcessor.new,
        repository: RegisterSourcesOc::Repository.new(
          RegisterSourcesOc::AddId,
          client: Config::ELASTICSEARCH_CLIENT,
          index: Config::ELASTICSEARCH_INDEX_ADD_IDS
        ),
        s3_adapter: Config::Adapters::S3_ADAPTER,
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET'),
        full_s3_prefix: ENV.fetch('ADD_IDS_EXPORT_JSON_FULL_S3_PREFIX')
      )
        super
      end
    end
  end
end
