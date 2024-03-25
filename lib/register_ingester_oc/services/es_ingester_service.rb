# frozen_string_literal: true

require 'register_common/services/file_reader'

require_relative '../config/adapters'
require_relative '../config/elasticsearch'
require_relative '../config/settings'

module RegisterIngesterOc
  module Services
    class EsIngesterService
      # rubocop:disable Metrics/ParameterLists
      def initialize(
        row_processor:,
        repository:,
        full_s3_prefix:,
        file_reader: nil,
        s3_adapter: Config::Adapters::S3_ADAPTER,
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET')
      )
        @row_processor = row_processor
        @repository = repository
        @s3_adapter = s3_adapter
        @file_reader = file_reader || RegisterCommon::Services::FileReader.new(s3_adapter:)
        @s3_bucket = s3_bucket
        @full_s3_prefix = full_s3_prefix
      end
      # rubocop:enable Metrics/ParameterLists

      def call(month)
        s3_prefix = File.join(full_s3_prefix, "mth=#{month}")

        # Calculate s3 paths to import
        s3_paths = s3_adapter.list_objects(s3_bucket:, s3_prefix:)
        print "IMPORTING S3 Paths:\n#{s3_paths} AT #{Time.now}\n\n"

        # Ingest S3 files
        s3_paths.each do |s3_path|
          print "STARTED IMPORTING #{s3_path} AT #{Time.now}\n"
          file_reader.read_from_s3(
            s3_bucket:,
            s3_path:,
            file_format: RegisterCommon::Parsers::FileFormats::JSON,
            compression: RegisterCommon::Decompressors::CompressionTypes::GZIP
          ) do |records|
            mapped_records = records.map { |record| row_processor.process_row record }
            repository.store mapped_records
          end
          print "COMPLETED IMPORTING #{s3_path} AT #{Time.now}\n"
        end

        print "\n\nINGEST FINISHED AT #{Time.now}\n\n\n"
      end

      private

      attr_reader :file_reader, :repository, :s3_adapter, :s3_bucket, :full_s3_prefix, :row_processor
    end
  end
end
