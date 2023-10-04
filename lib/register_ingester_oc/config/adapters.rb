# frozen_string_literal: true

require 'register_common/adapters/athena_adapter'
require 'register_common/adapters/s3_adapter'

require_relative '../adapters/sftp_adapter'
require_relative 'settings'

module RegisterIngesterOc
  module Config
    module Adapters
      ATHENA_ADAPTER = RegisterCommon::Adapters::AthenaAdapter.new(credentials: AWS_CREDENTIALS)
      S3_ADAPTER     = RegisterCommon::Adapters::S3Adapter.new(credentials: AWS_CREDENTIALS)
      SFTP_ADAPTER   = RegisterIngesterOc::Adapters::SftpAdapter.new
    end
  end
end
