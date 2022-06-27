#!/usr/bin/env ruby

require 'json'

require 'register_ingester_oc/config/settings'
require 'register_sources_oc/repositories/company_repository'
require 'register_sources_oc/services/company_service'

require 'register_ingester_oc/config/adapters'
require 'register_ingester_oc/config/elasticsearch'
require 'register_ingester_oc/services/company_file_reader'

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

        EsChecker.new.call(month: month, import_type: import_type)
      end

      def initialize(
        company_service: RegisterSourcesOc::Services::CompanyService.new(comparison_mode: true),
        file_reader: Services::CompanyFileReader.new,
        company_repository: RegisterSourcesOc::Repositories::CompanyRepository.new(client: Config::ELASTICSEARCH_CLIENT),
        s3_adapter: Config::Adapters::S3_ADAPTER,
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET'),
        diffs_s3_prefix: ENV.fetch('EXPORT_JSON_DIFFS_S3_PREFIX'),
        full_s3_prefix: ENV.fetch('EXPORT_JSON_FULL_S3_PREFIX')
      )
        @file_reader = file_reader
        @company_repository = company_repository
        @company_service = company_service
        @s3_adapter = s3_adapter
        @s3_bucket = s3_bucket
        @diffs_s3_prefix = diffs_s3_prefix
        @full_s3_prefix = full_s3_prefix
      end

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
        s3_paths = s3_adapter.list_objects(s3_bucket: s3_bucket, s3_prefix: s3_prefix)
        print "IMPORTING S3 Paths:\n#{s3_paths} AT #{Time.now}\n\n"

        # Ingest S3 files
        s3_paths.each do |s3_path|
          #print "\nIMPORTING #{s3_path}\n"
          #file_reader.import_from_s3(s3_bucket: s3_bucket, s3_path: s3_path, file_format: 'json') do |records|
          #  company_repository.store records
          #end

          print "\nCHECKING #{s3_path}\n"
          file_reader.import_from_s3(s3_bucket: s3_bucket, s3_path: s3_path, file_format: 'json') do |records|
            records.each do |record|
              perform_checks(record)
            end
          end
          print "\nCHECKED #{s3_path}\n"
        end

        print "\n\nCHECKING FINISHED AT #{Time.now}\n\n\n"
      end

      private

      attr_reader :file_reader, :company_repository, :company_service, :s3_adapter, :s3_bucket, :diffs_s3_prefix, :full_s3_prefix

      def perform_checks(record)
        jurisdiction_code = record.jurisdiction_code
        company_number = record.company_number
        name = record.name

        results = company_service.get_company(jurisdiction_code, company_number)
        if !results.empty?
          results.each do |result|
            unless (result[:response1].keys.map(&:to_sym) == [:registered_address_in_full]) && (result[:response2].keys.map(&:to_sym) == [:registered_address_in_full])
              print "get_company jurisdiction_code:#{jurisdiction_code} company_number:#{company_number} result:#{JSON.pretty_generate(result)}\n"
            end
          end
        end

        results = company_service.search_companies(jurisdiction_code, company_number)
        if !results.empty?
          results.each do |result|
            unless (result[:response1].keys.map(&:to_sym) == [:registered_address_in_full]) && (result[:response2].keys.map(&:to_sym) == [:registered_address_in_full])
              print "search_companies jurisdiction_code:#{jurisdiction_code} company_number:#{company_number} result:#{JSON.pretty_generate(result)}\n"
            end
          end
        end

        results = company_service.search_companies_by_name(name)
        if !results.empty?
          results.each do |result|
            unless (result[:response1].keys.map(&:to_sym) == [:registered_address_in_full]) && (result[:response2].keys.map(&:to_sym) == [:registered_address_in_full])
              print "search_companies_by_name name:#{name} result:#{JSON.pretty_generate(result)}\n"
            end
          end
        end
      end
    end
  end
end
