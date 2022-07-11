#!/usr/bin/env ruby

require 'register_ingester_oc/add_ids/es_ingestor_service'
require 'register_ingester_oc/alt_names/es_ingestor_service'
require 'register_ingester_oc/companies/es_ingestor_service'

module RegisterIngesterOc
  module Apps
    class EsIngestor
      def self.bash_call(args)
        oc_source = args[0]
        month = args[1]

        new().call(month, oc_source)
      end

      def call(month, oc_source)
        ingestor_service = select_ingestor_service(oc_source)
        ingestor_service.call month
      end

      private

      def select_ingestor_service(oc_source)
        case oc_source
        when 'companies'
          Companies::EsIngestorService.new
        when 'alt_names'
          AltNames::EsIngestorService.new
        when 'add_ids'
          AddIds::EsIngestorService.new
        else
          raise 'unknown oc_source'
        end
      end
    end
  end
end
