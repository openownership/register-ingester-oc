require 'register_ingester_oc/config/settings'
require 'register_ingester_oc/companies/exporter_service'

module RegisterIngesterOc
  module Apps
    class OcExporter
      def self.bash_call(args)
        month = args[0]

        OcExporter.new.call month
      end

      def initialize(
        exporter_service: Companies::ExporterService.new
      )
        @exporter_service = exporter_service
      end

      def call(month)
        exporter_service.call month
      end

      private

      attr_reader :exporter_service
    end
  end
end
