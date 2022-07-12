require 'register_ingester_oc/exceptions'
require 'register_ingester_oc/config/settings'
require 'register_ingester_oc/add_ids/create_tables_service'
require 'register_ingester_oc/alt_names/create_tables_service'
require 'register_ingester_oc/companies/create_tables_service'

module RegisterIngesterOc
  module Apps
    class TableCreator
      def self.bash_call(args)
        oc_source = args[0]

        TableCreator.new.call(oc_source)
      end

      def initialize(
        companies_table_service: Companies::CreateTablesService.new,
        alt_names_table_service: AltNames::CreateTablesService.new,
        add_ids_table_service: AddIds::CreateTablesService.new
      )
        @companies_table_service = companies_table_service
        @alt_names_table_service = alt_names_table_service
        @add_ids_table_service = add_ids_table_service
      end

      def call(oc_source)
        create_tables_service = select_create_tables_service(oc_source)
        create_tables_service.call
      end

      private

      attr_reader :companies_table_service, :alt_names_table_service, :add_ids_table_service

      def select_create_tables_service(oc_source)
        case oc_source
        when 'companies'
          companies_table_service
        when 'alt_names'
          alt_names_table_service
        when 'add_ids'
          add_ids_table_service
        else
          raise UnknownOcSourceError
        end
      end
    end
  end
end
