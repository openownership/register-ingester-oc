# frozen_string_literal: true

module RegisterIngesterOc
  module Adapters
    class SftpAdapter
      def download_file(host:, username:, rem_path:, dst_path:)
        `sftp #{username}@#{host}:#{rem_path} #{dst_path}`
      end
    end
  end
end
