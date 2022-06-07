require 'net/sftp'

module RegisterIngesterOc
  module Adapters
    class SftpAdapter
      def download_file(host:, username:, password:, rem_path:, dst_path:)
        Net::SFTP.start(host, username, password: password) do |sftp|
          sftp.download!(rem_path, dst_path)
        end
      end
    end
  end
end
