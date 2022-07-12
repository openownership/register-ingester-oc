require 'register_ingester_oc/services/es_ingestor_service'
require 'register_sources_oc/repositories/company_repository'
require 'register_ingester_oc/companies/file_reader'

module RegisterIngesterOc
  module Companies
    class EsIngestorService < Services::EsIngestorService
      def initialize(
        file_reader: Companies::FileReader.new,
        repository: RegisterSourcesOc::Repositories::CompanyRepository.new(client: Config::ELASTICSEARCH_CLIENT),
        s3_adapter: Config::Adapters::S3_ADAPTER,
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET'),
        full_s3_prefix: ENV.fetch('COMPANIES_EXPORT_JSON_FULL_S3_PREFIX')
      )
        super
      end
    end
  end
end
