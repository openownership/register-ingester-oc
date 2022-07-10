require 'register_ingester_oc/config/settings'
require 'register_ingester_oc/add_ids/exporter_service'
require 'register_ingester_oc/alt_names/exporter_service'
require 'register_ingester_oc/companies/exporter_service'

module RegisterIngesterOc
  module Apps
    class OcExporter
      def self.bash_call(args)
        month = args[0]
        oc_source = args[1]

        OcExporter.new.call month, oc_source
      end

      def call(month, oc_source)
        exporter_service = select_exporter_service(oc_source)
        exporter_service.call month
      end

      private

      def select_exporter_service(oc_source)
        case oc_source
        when 'companies'
          Companies::ExporterService.new
        when 'alt_names'
          AltNames::ExporterService.new
        when 'add_ids'
          AddIds::ExporterService.new
        else
          raise 'unknown oc_source'
        end
      end
    end
  end
end
