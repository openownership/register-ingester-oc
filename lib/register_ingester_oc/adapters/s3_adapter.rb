require 'aws-sdk-s3'

module RegisterIngesterOc
  module Adapters
    class S3Adapter
      module Errors
        NoSuchKey = Class.new(StandardError)
      end

      def initialize(region:, access_key_id:, secret_access_key:)
        @s3_client = Aws::S3::Client.new(
          region: region,
          access_key_id: access_key_id,
          secret_access_key: secret_access_key,
        )
      end

      def download_from_s3(s3_bucket:, s3_path:, local_path:)
        s3 = Aws::S3::Object.new(s3_bucket, s3_path, client: s3_client)
        s3.download_file(local_path)
      rescue Aws::S3::Errors::NoSuchKey, Aws::S3::Errors::NotFound
        raise Errors::NoSuchKey
      end

      def upload_to_s3(s3_bucket:, s3_path:, local_path:)
        s3 = Aws::S3::Object.new(s3_bucket, s3_path, client: s3_client)
        s3.upload_file(local_path)
      end
      
      def upload_from_file_obj_to_s3(s3_bucket:, s3_path:, stream:)
        s3_client.put_object(bucket: s3_bucket, key: s3_path, body: stream)
      rescue Aws::S3::Errors::NoSuchKey, Aws::S3::Errors::NotFound
        raise Errors::NoSuchKey
      end        

      private

      attr_reader :s3_client
    end
  end
end
