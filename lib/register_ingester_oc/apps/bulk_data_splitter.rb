require 'register_ingester_oc/config/settings'
require 'register_ingester_oc/services/oc_splitter_service'

module RegisterIngesterOc
  module Apps
    class BulkDataSplitter
      DEFAULT_SPLIT_SIZE = 2_000_000
      DEFAULT_MAX_LINES = nil

      def self.bash_call(args)
        month = args[0]
        local_path = args[1]
        oc_source = args[2]

        BulkDataSplitter.new.call(month: month, local_path: local_path, oc_source: oc_source)
      end

      def initialize(
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET'),
        splitter_service: Services::OcSplitterService.new,
        split_size: DEFAULT_SPLIT_SIZE,
        max_lines: DEFAULT_MAX_LINES
      )
        @s3_bucket = s3_bucket
        @splitter_service = splitter_service
        @split_size = split_size
        @max_lines = max_lines
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

      def select_s3_prefix(oc_source)
        case oc_source
        when 'companies'
          ENV.fetch('COMPANIES_BULK_DATA_S3_PREFIX')
        when 'alt_names'
          ENV.fetch('ALT_NAMES_BULK_DATA_S3_PREFIX')
        when 'add_identifiers'
          ENV.fetch('ADD_IDENTIFIERS_BULK_DATA_S3_PREFIX')
        else
          raise 'unknown oc_source'
        end
      end
    end
  end
end
