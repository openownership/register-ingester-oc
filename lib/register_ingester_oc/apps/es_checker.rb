# frozen_string_literal: true

require 'json'
require 'register_sources_oc/repository'
require 'register_sources_oc/services/company_service'

require_relative '../companies/file_reader'
require_relative '../config/adapters'
require_relative '../config/elasticsearch'
require_relative '../config/settings'

module RegisterIngesterOc
  module Apps
    class EsChecker
      UnknownImportTypeError = Class.new(StandardError)

      module ImportTypes
        DIFF = 'diff'
        FULL = 'full'
      end

      def self.bash_call(args)
        month = args[0]
        import_type = args[1]

        EsChecker.new.call(month:, import_type:)
      end

      # rubocop:disable Metrics/ParameterLists
      def initialize(
        company_service: RegisterSourcesOc::Services::CompanyService.new(comparison_mode: true),
        file_reader: Companies::FileReader.new,
        company_repository: RegisterSourcesOc::Repository.new(
          RegisterSourcesOc::Company,
          id_digest: false,
          client: Config::ELASTICSEARCH_CLIENT,
          index: RegisterSourcesOc::Config::ELASTICSEARCH_INDEX_COMPANIES
        ),
        s3_adapter: Config::Adapters::S3_ADAPTER,
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET'),
        diffs_s3_prefix: ENV.fetch('COMPANIES_EXPORT_JSON_DIFFS_S3_PREFIX'),
        full_s3_prefix: ENV.fetch('COMPANIES_EXPORT_JSON_FULL_S3_PREFIX')
      )
        @file_reader = file_reader
        @company_repository = company_repository
        @company_service = company_service
        @s3_adapter = s3_adapter
        @s3_bucket = s3_bucket
        @diffs_s3_prefix = diffs_s3_prefix
        @full_s3_prefix = full_s3_prefix
      end
      # rubocop:enable Metrics/ParameterLists

      def call(month:, import_type:)
        # Calculate s3 prefix
        s3_prefix_base =
          case import_type
          when ImportTypes::DIFF
            diffs_s3_prefix
          when ImportTypes::FULL
            full_s3_prefix
          else
            raise UnknownImportTypeError
          end
        s3_prefix = File.join(s3_prefix_base, "mth=#{month}")

        # Calculate s3 paths to import
        s3_paths = s3_adapter.list_objects(s3_bucket:, s3_prefix:)
        print "IMPORTING S3 Paths:\n#{s3_paths} AT #{Time.now}\n\n"

        # Ingest S3 files
        s3_paths.each do |s3_path|
          print "\nCHECKING #{s3_path}\n"
          file_reader.import_from_s3(s3_bucket:, s3_path:, file_format: 'json') do |records|
            records.each do |record|
              perform_checks(record)
            end
          end
          print "\nCHECKED #{s3_path}\n"
        end

        print "\n\nCHECKING FINISHED AT #{Time.now}\n\n\n"
      end

      private

      attr_reader :file_reader, :company_repository, :company_service, :s3_adapter, :s3_bucket, :diffs_s3_prefix,
                  :full_s3_prefix

      def perform_checks(record)
        jurisdiction_code = record.jurisdiction_code
        company_number = record.company_number
        record.name

        results = company_service.get_company(jurisdiction_code, company_number)
        unless results.empty?
          results.each do |result|
            print "get_company jurisdiction_code:#{jurisdiction_code} company_number:#{company_number} result:#{JSON.pretty_generate(result)}\n" # rubocop:disable Layout/LineLength
          end
        end

        results = company_service.search_companies(jurisdiction_code, company_number)
        return if results.empty?

        results.each do |result|
          print "search_companies jurisdiction_code:#{jurisdiction_code} company_number:#{company_number} result:#{JSON.pretty_generate(result)}\n" # rubocop:disable Layout/LineLength
        end
      end
    end
  end
end
