require 'register_ingester_oc/exceptions'
require 'register_ingester_oc/config/settings'
require 'register_ingester_oc/services/oc_splitter_service'

module RegisterIngesterOc
  module Apps
    class BulkDataSplitter
      DEFAULT_SPLIT_SIZE = 2_000_000
      DEFAULT_MAX_LINES = nil

      def self.bash_call(args)
        oc_source = args[0]
        month = args[1]
        local_path = args[2]

        BulkDataSplitter.new.call(month: month, local_path: local_path, oc_source: oc_source)
      end

      def initialize(
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET'),
        splitter_service: Services::OcSplitterService.new,
        split_size: DEFAULT_SPLIT_SIZE,
        max_lines: DEFAULT_MAX_LINES,
        companies_s3_prefix: ENV.fetch('COMPANIES_BULK_DATA_S3_PREFIX'),
        alt_names_s3_prefix: ENV.fetch('ALT_NAMES_BULK_DATA_S3_PREFIX'),
        add_ids_s3_prefix: ENV.fetch('ADD_IDS_BULK_DATA_S3_PREFIX')
      )
        @s3_bucket = s3_bucket
        @splitter_service = splitter_service
        @split_size = split_size
        @max_lines = max_lines
        @companies_s3_prefix = companies_s3_prefix
        @alt_names_s3_prefix = alt_names_s3_prefix
        @add_ids_s3_prefix = add_ids_s3_prefix
      end

      def call(month:, local_path:, oc_source:)
        s3_prefix = select_s3_prefix(oc_source)
        dst_prefix = File.join(s3_prefix, "mth=#{month}")

        File.open(local_path, 'rb') do |stream|
          splitter_service.split_file(
            stream,
            s3_bucket: s3_bucket,
            s3_prefix: dst_prefix,
            split_size: split_size,
            max_lines: max_lines
          )
        end        
      end

      private

      attr_reader :s3_bucket, :s3_prefix, :splitter_service, :split_size, :max_lines
      attr_reader :companies_s3_prefix, :alt_names_s3_prefix, :add_ids_s3_prefix

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
