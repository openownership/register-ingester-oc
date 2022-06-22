require 'register_ingester_oc/config/settings'
require 'register_ingester_oc/services/oc_splitter_service'

module RegisterIngesterOc
  module Apps
    class BulkDataSplitter
      DEFAULT_SPLIT_SIZE = 10_000
      DEFAULT_MAX_LINES = 500_000

      def self.bash_call(args)
        month = args[0]
        local_path = args[1]

        BulkDataSplitter.new.call(month: month, local_path: local_path)
      end

      def initialize(
        s3_bucket:,
        s3_prefix:,
        splitter_service: Services::OcSplitterService.new,
        split_size: DEFAULT_SPLIT_SIZE,
        max_lines: DEFAULT_MAX_LINES
      )
        @s3_bucket = s3_bucket
        @s3_prefix = s3_prefix
        @splitter_service = splitter_service
        @split_size = split_size
        @max_lines = max_lines
      end

      def call(month:, local_path:)
        dst_prefix = File.join(s3_prefix, "mth2=#{month}")

        File.open(dst_path, 'rb') do |stream|
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
    end
  end
end
