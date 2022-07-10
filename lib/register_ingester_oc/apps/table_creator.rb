require 'register_ingester_oc/config/settings'
require 'register_ingester_oc/companies/create_tables_service'

module RegisterIngesterOc
  module Apps
    class TableCreator
      def self.bash_call
        TableCreator.new.call
      end

      def initialize(
        create_tables_service: Companies::CreateTablesService.new
      )
        @create_tables_service = create_tables_service
      end

      def call
        create_tables_service.call
      end

      private

      attr_reader :create_tables_service
    end
  end
end
