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

      def call(oc_source)
        create_tables_service = select_create_tables_service(oc_source)
        create_tables_service.call
      end

      private

      def select_create_tables_service(oc_source)
        case oc_source
        when 'companies'
          Companies::CreateTablesService.new
        when 'alt_names'
          AltNames::CreateTablesService.new
        when 'add_ids'
          AddIds::CreateTablesService.new
        else
          raise 'unknown oc_source'
        end
      end
    end
  end
end
