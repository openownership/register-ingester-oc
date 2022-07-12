require 'register_ingester_oc/config/settings'
require 'register_ingester_oc/config/adapters'
require 'register_ingester_oc/config/elasticsearch'

module RegisterIngesterOc
  module Services
    class EsIngestorService
      def initialize(
        file_reader:,
        repository:,
        full_s3_prefix:,
        s3_adapter: Config::Adapters::S3_ADAPTER,
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET')
      )
        @file_reader = file_reader
        @repository = repository
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
            repository.store records
          end
          print "COMPLETED IMPORTING #{s3_path} AT #{Time.now}\n"
        end

        print "\n\nINGEST FINISHED AT #{Time.now}\n\n\n"
      end

      private

      attr_reader :file_reader, :repository, :s3_adapter, :s3_bucket, :full_s3_prefix
    end
  end
end
