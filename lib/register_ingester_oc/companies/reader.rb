require 'register_ingester_oc/utils/generic_reader'
require 'register_sources_oc/structs/company'

module RegisterIngesterOc
  module Companies
    class Reader < Utils::GenericReader
      private

      def process_row(row)
        registered_address_in_full = row['registered_address.in_full'].presence && row['registered_address.in_full'].presence.gsub("\\n", "\n")
        registered_address_country = row['registered_address.country'].presence

        # Bulk is inconsistent with API as the registered_address.in_full includes country
        # This strips it out to make it match
        if registered_address_country && registered_address_in_full
          if registered_address_in_full.end_with? ", #{registered_address_country}"
            registered_address_in_full = registered_address_in_full[0...-(registered_address_country.length + 2)]
          end
        end

        RegisterSourcesOc::Company.new(
          company_number: row['company_number'].presence,
          jurisdiction_code: row['jurisdiction_code'].presence,
          name: row['name'].presence,
          company_type: row['company_type'].presence,
          incorporation_date: row['incorporation_date'].presence,
          dissolution_date: row['dissolution_date'].presence,
          restricted_for_marketing: row['restricted_for_marketing'],
          registered_address_in_full: registered_address_in_full,
          registered_address_country: registered_address_country
        )
      end
    end
  end
end
