require 'register_common/adapters/s3_adapter'

require 'register_ingester_oc/adapters/athena_adapter'
require 'register_ingester_oc/adapters/sftp_adapter'
require 'register_ingester_oc/config/settings'

module RegisterIngesterOc
  module Config
    module Adapters
      S3_ADAPTER = RegisterCommon::Adapters::S3Adapter.new(credentials: AWS_CREDENTIALS)

      ATHENA_ADAPTER = RegisterIngesterOc::Adapters::AthenaAdapter.new
      SFTP_ADAPTER = RegisterIngesterOc::Adapters::SftpAdapter.new
    end
  end
end
