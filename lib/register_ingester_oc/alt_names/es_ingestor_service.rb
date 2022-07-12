require 'register_ingester_oc/services/es_ingestor_service'
require 'register_sources_oc/repositories/alt_name_repository'
require 'register_ingester_oc/alt_names/file_reader'

module RegisterIngesterOc
  module AltNames
    class EsIngestorService < Services::EsIngestorService
      def initialize(
        file_reader: AltNames::FileReader.new,
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
