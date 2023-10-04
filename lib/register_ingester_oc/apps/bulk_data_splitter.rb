# frozen_string_literal: true

require 'register_common/decompressors/decompressor'
require 'register_common/services/stream_uploader_service'

require_relative '../config/adapters'
require_relative '../exceptions'

module RegisterIngesterOc
  module Apps
    class BulkDataSplitter
      DEFAULT_MAX_LINES  = nil
      DEFAULT_SPLIT_SIZE = 2_000_000

      def self.bash_call(args)
        oc_source = args[0]
        month = args[1]
        local_path = args[2]

        BulkDataSplitter.new.call(month:, local_path:, oc_source:)
      end

      # rubocop:disable Metrics/ParameterLists
      def initialize(
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET'),
        stream_uploader_service: nil,
        split_size: DEFAULT_SPLIT_SIZE,
        max_lines: DEFAULT_MAX_LINES,
        stream_decompressor: nil,
        companies_s3_prefix: ENV.fetch('COMPANIES_BULK_DATA_S3_PREFIX'),
        alt_names_s3_prefix: ENV.fetch('ALT_NAMES_BULK_DATA_S3_PREFIX'),
        add_ids_s3_prefix: ENV.fetch('ADD_IDS_BULK_DATA_S3_PREFIX')
      )
        @s3_bucket = s3_bucket
        @stream_decompressor = stream_decompressor || RegisterCommon::Decompressors::Decompressor.new
        @stream_uploader_service = stream_uploader_service || RegisterCommon::Services::StreamUploaderService.new(
          s3_adapter: Config::Adapters::S3_ADAPTER
        )
        @split_size = split_size
        @max_lines = max_lines
        @companies_s3_prefix = companies_s3_prefix
        @alt_names_s3_prefix = alt_names_s3_prefix
        @add_ids_s3_prefix = add_ids_s3_prefix
      end
      # rubocop:enable Metrics/ParameterLists

      def call(month:, local_path:, oc_source:)
        s3_prefix = select_s3_prefix(oc_source)
        dst_prefix = File.join(s3_prefix, "mth=#{month}")

        File.open(local_path, 'rb') do |stream|
          stream_decompressor.with_deflated_stream(
            stream,
            compression: RegisterCommon::Decompressors::CompressionTypes::GZIP
          ) do |deflated|
            stream_uploader_service.upload_in_parts(
              deflated,
              s3_bucket:,
              s3_prefix: dst_prefix,
              split_size:,
              max_lines:
            )
          end
        end
      end

      private

      attr_reader :s3_bucket, :s3_prefix, :stream_uploader_service, :split_size, :max_lines, :companies_s3_prefix,
                  :alt_names_s3_prefix, :add_ids_s3_prefix, :stream_decompressor

      def select_s3_prefix(oc_source)
        case oc_source
        when 'companies'
          companies_s3_prefix
        when 'alt_names'
          alt_names_s3_prefix
        when 'add_ids'
          add_ids_s3_prefix
        else
          raise UnknownOcSourceError
        end
      end
    end
  end
end
