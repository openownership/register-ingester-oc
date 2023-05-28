require 'register_ingester_oc/exceptions'
require 'register_ingester_oc/config/settings'
require 'register_ingester_oc/services/download_service'

module RegisterIngesterOc
  module Apps
    class OcDownloader
      def self.bash_call(args)
        oc_source = args[0]
        month = args[1]
        dst_path = args[2]

        OcDownloader.new.call oc_source, month, dst_path
      end

      def initialize(download_service: Services::DownloadService.new)
        @download_service = download_service
      end

      def call(oc_source, month, dst_path)
        filename = select_filename(oc_source)

        print "DOWNLOADING #{filename} #{Time.now} to #{dst_path}\n"

        download_service.download(month, dst_path, filename:)

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
        when 'add_ids'
          'additional_identifiers.csv.gz'
        else
          raise UnknownOcSourceError
        end
      end
    end
  end
end
