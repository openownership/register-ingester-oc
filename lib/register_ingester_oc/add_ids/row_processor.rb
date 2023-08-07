require 'register_sources_oc/structs/add_id'

module RegisterIngesterOc
  module AddIds
    class RowProcessor
      def process_row(row)
        row = row.transform_values { |v| (v == '') ? nil : v }
        row = row.transform_keys(&:to_sym)

        RegisterSourcesOc::AddId.new(
          company_number: row[:company_number],
          jurisdiction_code: row[:jurisdiction_code],
          uid: row[:uid],
          identifier_system_code: row[:identifier_system_code]
        )
      end
    end
  end
end
