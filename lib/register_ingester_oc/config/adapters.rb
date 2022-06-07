require 'register_ingester_oc/adapters/sftp_adapter'

module RegisterIngesterOc
  module Config
    module Adapters
      SFTP_ADAPTER = RegisterIngesterOc::Adapters::SftpAdapter.new
    end
  end
end
