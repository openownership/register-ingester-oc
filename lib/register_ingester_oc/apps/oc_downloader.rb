require 'register_ingester_oc/config/settings'
require 'register_ingester_oc/services/download_service'

module RegisterIngesterOc
  module Apps
    class OcDownloader
      def self.bash_call(args)
        month = args[0]
        dst_path = args[1]
        oc_source = args[2]

        OcDownloader.new.call month, dst_path, oc_source
      end

      def initialize(
        download_service: Services::DownloadService.new
      )
        @download_service = download_service
      end

      def call(month, dst_path, oc_source)
        filename = select_filename(oc_source)

        print "DOWNLOADING #{filename} #{Time.now} to #{dst_path}\n"

        download_service.download(month, dst_path, filename: filename)

        print "DOWNLOADED #{filename} #{Time.now} to #{dst_path}\n"
      end

      private

      attr_reader :download_service

      def select_filename(oc_source)
        case oc_source
        when 'companies'
          'companies.csv.gz'
        when 'alt_names'
          'alternative_names.csv.gz'
        when 'add_identifiers'
          'additional_identifiers.csv.gz'
        else
          raise 'unknown oc_source'
        end
      end
    end
  end
end
