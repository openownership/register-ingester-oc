module RegisterIngesterOc
  module Adapters
    class SftpAdapter
      def download_file(host:, username:, password:, rem_path:, dst_path:)
        `sftp #{username}@#{host}:#{rem_path} #{dst_path}`
      end
    end
  end
end
