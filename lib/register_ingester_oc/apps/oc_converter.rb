require 'register_ingester_oc/config/settings'
require 'register_ingester_oc/add_ids/conversion_service'
require 'register_ingester_oc/alt_names/conversion_service'
require 'register_ingester_oc/companies/conversion_service'

module RegisterIngesterOc
  module Apps
    class OcConverter
      def self.bash_call(args)
        oc_source = args[0]
        month = args[1]

        OcConverter.new.call month, oc_source
      end

      def call(month, oc_source)
        conversion_service = select_conversion_service(oc_source)
        conversion_service.call month
      end

      private

      def select_conversion_service(oc_source)
        case oc_source
        when 'companies'
          Companies::ConversionService.new
        when 'alt_names'
          AltNames::ConversionService.new
        when 'add_ids'
          AddIds::ConversionService.new
        else
          raise 'unknown oc_source'
        end
      end
    end
  end
end
