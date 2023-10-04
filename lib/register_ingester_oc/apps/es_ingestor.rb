# frozen_string_literal: true

require_relative '../add_ids/es_ingestor_service'
require_relative '../alt_names/es_ingestor_service'
require_relative '../companies/es_ingestor_service'
require_relative '../exceptions'

module RegisterIngesterOc
  module Apps
    class EsIngestor
      def self.bash_call(args)
        oc_source = args[0]
        month = args[1]

        new.call(oc_source, month)
      end

      def initialize(
        companies_ingestor_service: Companies::EsIngestorService.new,
        alt_names_ingestor_service: AltNames::EsIngestorService.new,
        add_ids_ingestor_service: AddIds::EsIngestorService.new
      )
        @companies_ingestor_service = companies_ingestor_service
        @alt_names_ingestor_service = alt_names_ingestor_service
        @add_ids_ingestor_service = add_ids_ingestor_service
      end

      def call(oc_source, month)
        ingestor_service = select_ingestor_service(oc_source)
        ingestor_service.call month
      end

      private

      attr_reader :companies_ingestor_service, :alt_names_ingestor_service, :add_ids_ingestor_service

      def select_ingestor_service(oc_source)
        case oc_source
        when 'companies'
          companies_ingestor_service
        when 'alt_names'
          alt_names_ingestor_service
        when 'add_ids'
          add_ids_ingestor_service
        else
          raise UnknownOcSourceError
        end
      end
    end
  end
end
