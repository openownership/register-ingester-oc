require 'register_ingester_oc/utils/generic_reader'
require 'register_sources_oc/structs/add_id'

module RegisterIngesterOc
  module AddIds
    class Reader < Utils::GenericReader
      private

      def process_row(row)
        RegisterSourcesOc::AddId.new(
          company_number: row['company_number'].presence,
          jurisdiction_code: row['jurisdiction_code'].presence,
          uid: row['uid'].presence,
          identifier_system_code: row['identifier_system_code'].presence
        )
      end
    end
  end
end
