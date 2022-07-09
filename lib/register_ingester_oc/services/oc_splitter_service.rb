require 'register_ingester_oc/config/adapters'
require 'register_ingester_oc/utils/gzip_reader'
require 'register_ingester_oc/services/file_splitter_service'

module RegisterIngesterOc
  module Services
    class OcSplitterService
      DEFAULT_LINES_PER_FILE = 2_500_000
      MAX_PARTS = 98

      def initialize(
        s3_adapter: Config::Adapters::S3_ADAPTER,
        file_splitter_service: Services::FileSplitterService.new,
        gzip_reader: Utils::GzipReader.new,
        max_parts: MAX_PARTS
      )
        @s3_adapter = s3_adapter
        @file_splitter_service = file_splitter_service
        @gzip_reader = gzip_reader
        @max_parts = max_parts
      end

      def split_file(stream, s3_bucket:, s3_prefix:, split_size: DEFAULT_LINES_PER_FILE, max_lines: nil)
        gzip_reader.open_stream(stream) do |unzipped_stream|
          file_index = 0
          file_splitter_service.split_stream(unzipped_stream, split_size: split_size, max_lines: max_lines) do |split_file_path|
            print "DEALING WITH PATH ", split_file_path, "\n"
            part = part_for_file_index file_index
            s3_path = File.join(s3_prefix, "part=part#{part}", "file-#{file_index}.csv.gz")
            s3_adapter.upload_to_s3(s3_bucket: s3_bucket, s3_path: s3_path, local_path: split_file_path)
            file_index += 1
          end
        end
      end

      private

      attr_reader :s3_adapter, :file_splitter_service, :gzip_reader, :max_parts

      def part_for_file_index(file_index)
        file_index % max_parts
      end
    end
  end
end
