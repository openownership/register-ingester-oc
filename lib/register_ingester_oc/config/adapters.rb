require 'register_ingester_oc/adapters/athena_adapter'
require 'register_ingester_oc/adapters/s3_adapter'
require 'register_ingester_oc/adapters/sftp_adapter'

module RegisterIngesterOc
  module Config
    module Adapters
      ATHENA_ADAPTER = RegisterIngesterOc::Adapters::AthenaAdapter.new
      S3_ADAPTER = RegisterIngesterOc::Adapters::S3Adapter.new
      SFTP_ADAPTER = RegisterIngesterOc::Adapters::SftpAdapter.new
    end
  end
end
