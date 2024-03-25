# frozen_string_literal: true

require_relative '../add_ids/es_ingester_service'
require_relative '../alt_names/es_ingester_service'
require_relative '../companies/es_ingester_service'
require_relative '../exceptions'

module RegisterIngesterOc
  module Apps
    class EsIngester
      def self.bash_call(args)
        oc_source = args[0]
        month = args[1]

        new.call(oc_source, month)
      end

      def initialize(
        companies_ingester_service: Companies::EsIngesterService.new,
        alt_names_ingester_service: AltNames::EsIngesterService.new,
        add_ids_ingester_service: AddIds::EsIngesterService.new
      )
        @companies_ingester_service = companies_ingester_service
        @alt_names_ingester_service = alt_names_ingester_service
        @add_ids_ingester_service = add_ids_ingester_service
      end

      def call(oc_source, month)
        ingester_service = select_ingester_service(oc_source)
        ingester_service.call month
      end

      private

      attr_reader :companies_ingester_service, :alt_names_ingester_service, :add_ids_ingester_service

      def select_ingester_service(oc_source)
        case oc_source
        when 'companies'
          companies_ingester_service
        when 'alt_names'
          alt_names_ingester_service
        when 'add_ids'
          add_ids_ingester_service
        else
          raise UnknownOcSourceError
        end
      end
    end
  end
end
