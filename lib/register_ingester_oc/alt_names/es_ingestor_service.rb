#!/usr/bin/env ruby

require 'register_ingester_oc/config/settings'
require 'register_sources_oc/repositories/alt_name_repository'

require 'register_ingester_oc/config/adapters'
require 'register_ingester_oc/config/elasticsearch'
require 'register_ingester_oc/config/settings'
require 'register_ingester_oc/alt_names/file_reader'

module RegisterIngesterOc
  module AltNames
    class EsIngestorService
      def initialize(
        file_reader: AltNames::FileReader.new,
        alt_name_repository: RegisterSourcesOc::Repositories::AltNameRepository.new(client: Config::ELASTICSEARCH_CLIENT),
        s3_adapter: Config::Adapters::S3_ADAPTER,
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET'),
        full_s3_prefix: ENV.fetch('ALT_NAMES_EXPORT_JSON_FULL_S3_PREFIX')
      )
        @file_reader = file_reader
        @alt_name_repository = alt_name_repository
        @s3_adapter = s3_adapter
        @s3_bucket = s3_bucket
        @full_s3_prefix = full_s3_prefix
      end

      def call(month)
        s3_prefix = File.join(full_s3_prefix, "mth=#{month}")

        # Calculate s3 paths to import
        s3_paths = s3_adapter.list_objects(s3_bucket: s3_bucket, s3_prefix: s3_prefix)
        print "IMPORTING S3 Paths:\n#{s3_paths} AT #{Time.now}\n\n"

        # Ingest S3 files
        s3_paths.each do |s3_path|
          print "STARTED IMPORTING #{s3_path} AT #{Time.now}\n"
          file_reader.import_from_s3(s3_bucket: s3_bucket, s3_path: s3_path, file_format: 'json') do |records|
            alt_name_repository.store records
          end
          print "COMPLETED IMPORTING #{s3_path} AT #{Time.now}\n"
        end

        print "\n\nINGEST FINISHED AT #{Time.now}\n\n\n"
      end

      private

      attr_reader :file_reader, :alt_name_repository, :s3_adapter, :s3_bucket, :full_s3_prefix
    end
  end
end
