require 'register_ingester_oc/config/settings'
require 'register_ingester_oc/services/download_service'

module RegisterIngesterOc
  module Apps
    class OcDownloader
      def self.bash_call(args)
        month = args[0]
        dst_path = args[1]

        OcDownloader.new.call month, dst_path
      end

      def initialize(
        download_service: Services::DownloadService.new
      )
        @download_service = download_service
      end

      def call(month, dst_path)
        print "DOWNLOADING #{Time.now} to #{dst_path}\n"

        download_service.download(month, dst_path)

        print "DOWNLOADED #{Time.now} to #{dst_path}\n"
      end

      private

      attr_reader :download_service
    end
  end
end
