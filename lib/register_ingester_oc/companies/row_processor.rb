require 'register_sources_oc/structs/company'

module RegisterIngesterOc
  module Companies
    class RowProcessor
      def process_row(row)
        row = row.transform_values { |v| v == '' ? nil : v }
        row = row.transform_keys(&:to_sym)

        registered_address_in_full = row[:'registered_address.in_full']&.gsub("\\n", "\n")
        registered_address_country = row[:'registered_address.country']

        # Bulk is inconsistent with API as the registered_address.in_full includes country
        # This strips it out to make it match
        if registered_address_country && registered_address_in_full && (registered_address_in_full.end_with? ", #{registered_address_country}")
          registered_address_in_full = registered_address_in_full[0...-(registered_address_country.length + 2)]
        end

        RegisterSourcesOc::Company.new(
          company_number: row[:company_number],
          jurisdiction_code: row[:jurisdiction_code],
          name: row[:name],
          company_type: row[:company_type],
          incorporation_date: row[:incorporation_date],
          dissolution_date: row[:dissolution_date],
          restricted_for_marketing: row[:restricted_for_marketing],
          registered_address_in_full:,
          registered_address_country:,
        )
      end
    end
  end
end
