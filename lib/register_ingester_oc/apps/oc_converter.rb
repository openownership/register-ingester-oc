# frozen_string_literal: true

require_relative '../add_ids/conversion_service'
require_relative '../alt_names/conversion_service'
require_relative '../companies/conversion_service'
require_relative '../config/settings'
require_relative '../exceptions'

module RegisterIngesterOc
  module Apps
    class OcConverter
      def self.bash_call(args)
        oc_source = args[0]
        month = args[1]

        OcConverter.new.call oc_source, month
      end

      def initialize(
        companies_conversion_service: Companies::ConversionService.new,
        alt_names_conversion_service: AltNames::ConversionService.new,
        add_ids_conversion_service: AddIds::ConversionService.new
      )
        @companies_conversion_service = companies_conversion_service
        @alt_names_conversion_service = alt_names_conversion_service
        @add_ids_conversion_service = add_ids_conversion_service
      end

      def call(oc_source, month)
        conversion_service = select_conversion_service(oc_source)
        conversion_service.call month
      end

      private

      attr_reader :companies_conversion_service, :alt_names_conversion_service, :add_ids_conversion_service

      def select_conversion_service(oc_source)
        case oc_source
        when 'companies'
          companies_conversion_service
        when 'alt_names'
          alt_names_conversion_service
        when 'add_ids'
          add_ids_conversion_service
        else
          raise UnknownOcSourceError
        end
      end
    end
  end
end
