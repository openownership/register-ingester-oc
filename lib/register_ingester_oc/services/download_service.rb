require 'register_ingester_oc/config/adapters'
require 'register_ingester_oc/config/settings'

module RegisterIngesterOc
  module Services
    class DownloadService
      FILENAME = 'companies.csv.gz'

      def initialize(
        sftp_adapter: Config::Adapters::SFTP_ADAPTER,
        filename: FILENAME,
        settings: Config::SETTINGS
      )
        @sftp_adapter = sftp_adapter
        @filename = filename
        @settings = settings
      end

      def download(month, dst_path) # 2022_05
        rem_path = File.join('/', month, filename)
        sftp_adapter.download_file(
          host: settings.OC_HOST,
          username: settings.OC_USERNAME,
          password: settings.OC_PASSWORD,
          rem_path: rem_path,
          dst_path: dst_path
        )
      end

      def remote_file_stream(month, &block) # 2022_05
        rem_path = File.join('/', month, filename)
        sftp_adapter.remote_file_stream(
          host: settings.OC_HOST,
          username: settings.OC_USERNAME,
          password: settings.OC_PASSWORD,
          rem_path: rem_path,
          &block
        )
      end

      private

      attr_reader :sftp_adapter, :filename, :settings
    end
  end
end
