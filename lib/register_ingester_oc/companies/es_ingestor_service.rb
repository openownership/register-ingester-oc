# frozen_string_literal: true

require 'register_sources_oc/repository'

require_relative '../services/es_ingestor_service'
require_relative 'row_processor'

module RegisterIngesterOc
  module Companies
    class EsIngestorService < Services::EsIngestorService
      def initialize(
        row_processor: Companies::RowProcessor.new,
        repository: RegisterSourcesOc::Repository.new(
          RegisterSourcesOc::Company,
          id_digest: false,
          client: Config::ELASTICSEARCH_CLIENT,
          index: Config::ELASTICSEARCH_INDEX_COMPANIES
        ),
        s3_adapter: Config::Adapters::S3_ADAPTER,
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET'),
        full_s3_prefix: ENV.fetch('COMPANIES_EXPORT_JSON_FULL_S3_PREFIX')
      )
        super
      end
    end
  end
end
