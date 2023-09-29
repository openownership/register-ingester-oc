# frozen_string_literal: true

require 'register_ingester_oc/exceptions'
require 'register_ingester_oc/config/settings'
require 'register_ingester_oc/add_ids/exporter_service'
require 'register_ingester_oc/alt_names/exporter_service'
require 'register_ingester_oc/companies/exporter_service'

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
