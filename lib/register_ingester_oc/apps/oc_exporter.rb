# frozen_string_literal: true

require_relative '../add_ids/exporter_service'
require_relative '../alt_names/exporter_service'
require_relative '../companies/exporter_service'
require_relative '../config/settings'
require_relative '../exceptions'

module RegisterIngesterOc
  module Apps
    class OcExporter
      def self.bash_call(args)
        oc_source = args[0]
        month = args[1]

        OcExporter.new.call oc_source, month
      end

      def initialize(
        companies_exporter_service: Companies::ExporterService.new,
        alt_names_exporter_service: AltNames::ExporterService.new,
        add_ids_exporter_service: AddIds::ExporterService.new
      )
        @companies_exporter_service = companies_exporter_service
        @alt_names_exporter_service = alt_names_exporter_service
        @add_ids_exporter_service = add_ids_exporter_service
      end

      def call(oc_source, month)
        exporter_service = select_exporter_service(oc_source)
        exporter_service.call month
      end

      private

      attr_reader :companies_exporter_service, :alt_names_exporter_service, :add_ids_exporter_service

      def select_exporter_service(oc_source)
        case oc_source
        when 'companies'
          companies_exporter_service
        when 'alt_names'
          alt_names_exporter_service
        when 'add_ids'
          add_ids_exporter_service
        else
          raise UnknownOcSourceError
        end
      end
    end
  end
end
