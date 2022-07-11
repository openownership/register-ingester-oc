require 'register_ingester_oc/utils/generic_reader'
require 'register_sources_oc/structs/alt_name'

module RegisterIngesterOc
  module AltNames
    class Reader < Utils::GenericReader
      private

      def process_row(row)
        RegisterSourcesOc::AltName.new(
          company_number: row['company_number'].presence,
          jurisdiction_code: row['jurisdiction_code'].presence,
          name: row['name'].presence,
          type: row['type'].presence,
          start_date: row['start_date'].presence,
          end_date: row['end_date'].presence
        )
      end
    end
  end
end
