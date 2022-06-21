require 'tmpdir'
require 'register_ingester_oc/config/adapters'
require 'register_ingester_oc/services/company_reader'

module RegisterIngesterOc
  module Services
    class CompanyFileReader
      BATCH_SIZE = 100

      def initialize(
        reader: CompanyReader.new,
        s3_adapter: Config::Adapters::S3_ADAPTER,
        batch_size: BATCH_SIZE
      )
        @reader = reader
        @s3_adapter = s3_adapter
        @batch_size = batch_size
      end

      def import_from_s3(s3_bucket:, s3_path:, file_format: 'csv', zipped: true, &block)
        Dir.mktmpdir do |dir|
          file_path = File.join(dir, "tmpfile")
          s3_adapter.download_from_s3(s3_bucket: s3_bucket, s3_path: s3_path, local_path: file_path)
          import_from_local_path(file_path, file_format: file_format, zipped: zipped, &block)
        end
      end

      def import_from_local_path(file_path, file_format: 'csv', zipped: true, &block)
        File.open(file_path, 'r') do |stream|
          import_from_stream(stream, file_format: file_format, zipped: zipped, &block)
        end
      end

      def import_from_stream(stream, file_format: 'csv', zipped: true)
        batch_records = []

        reader.foreach(stream, file_format: file_format, zipped: zipped) do |record|
          batch_records << record
          next unless (batch_records.length >= batch_size)
          yield batch_records
          batch_records = []
        end
        unless batch_records.empty?
          yield batch_records
        end
      end

      private

      attr_reader :s3_adapter, :reader, :batch_size
    end
  end
end
