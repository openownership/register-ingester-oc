require 'register_ingester_oc/config/settings'
require 'register_ingester_oc/companies/conversion_service'

module RegisterIngesterOc
  module Apps
    class OcConverter
      def self.bash_call(args)
        month = args[0]

        OcConverter.new.call month
      end

      def initialize(
        conversion_service: Companies::ConversionService.new
      )
        @conversion_service = conversion_service
      end

      def call(month)
        conversion_service.call month
      end

      private

      attr_reader :conversion_service
    end
  end
end
