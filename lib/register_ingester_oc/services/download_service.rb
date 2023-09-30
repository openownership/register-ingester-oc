# frozen_string_literal: true

require 'register_ingester_oc/config/adapters'
require 'register_ingester_oc/config/settings'

module RegisterIngesterOc
  module Services
    class DownloadService
      def initialize(
        sftp_adapter: Config::Adapters::SFTP_ADAPTER,
        settings: Config::SETTINGS
      )
        @sftp_adapter = sftp_adapter
        @settings = settings
      end

      def download(month, dst_path, filename:)
        rem_path = File.join('/', month, filename)
        sftp_adapter.download_file(
          host: settings.OC_HOST,
          username: settings.OC_USERNAME,
          rem_path:,
          dst_path:
        )
      end

      private

      attr_reader :sftp_adapter, :settings
    end
  end
end
