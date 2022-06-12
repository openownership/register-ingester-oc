require 'tmpdir'
require 'register_ingester_oc/config/adapters'
require 'register_ingester_oc/services/company_reader'

module RegisterIngesterOc
  module Services
    class CompanyImporter
      BATCH_SIZE = 100

      def initialize(
        company_repository:,
        reader: CompanyReader.new,
        s3_adapter: Config::Adapters::S3_ADAPTER
      )
        @company_repository = company_repository
        @reader = reader
        @s3_adapter = s3_adapter
      end

      def import_from_s3(s3_bucket:, s3_path:, file_format: 'csv', zipped: true)
        Dir.mktmpdir do |dir|
          file_path = File.join(dir, "tmpfile")
          s3_adapter.download_from_s3(s3_bucket: s3_bucket, s3_path: s3_path, local_path: file_path)
          import_from_local_path(file_path, file_format: file_format, zipped: zipped)
        end
      end

      def import_from_local_path(file_path, file_format: 'csv', zipped: true)
        File.open(file_path, 'r') do |stream|
          import_from_stream(stream, file_format: file_format, zipped: zipped)
        end
      end

      def import_from_stream(stream, file_format: 'csv', zipped: true)
        batch_records = []

        reader.foreach(stream, file_format: file_format, zipped: zipped) do |record|
          batch_records << record
          next unless (batch_records.length >= BATCH_SIZE)
          # company_repository.store batch_records
          print "STORING RECORDS: ", batch_records, "\n\n\n"
          batch_records = []
        end
        unless batch_records.empty?
          # company_repository.store batch_records
        end
      end

      private

      attr_reader :company_repository, :s3_adapter, :reader
    end
  end
end
