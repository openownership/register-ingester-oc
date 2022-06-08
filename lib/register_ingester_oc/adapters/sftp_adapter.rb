require 'net/sftp'

module RegisterIngesterOc
  module Adapters
    class SftpAdapter
      def download_file(host:, username:, password:, rem_path:, dst_path:)
        # Net::SFTP.start(host, username, password: password) do |sftp|
        #  sftp.download!(rem_path, dst_path)
        # end

        `sftp #{username}@#{host}:#{rem_path} #{dst_path}`
      end

      def remote_file_stream(host:, username:, password:, rem_path:)
        Net::SFTP.start(host, username, password: password) do |sftp|
          sftp.file.open(rem_path, "r") do |stream|
            yield stream
          end
        end
      end
    end
  end
end
