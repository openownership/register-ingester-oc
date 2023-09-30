# frozen_string_literal: true

require 'register_sources_oc/structs/alt_name'

module RegisterIngesterOc
  module AltNames
    class RowProcessor
      def process_row(row)
        row = row.transform_values { |v| v == '' ? nil : v }
        row = row.transform_keys(&:to_sym)

        RegisterSourcesOc::AltName.new(
          company_number: row[:company_number],
          jurisdiction_code: row[:jurisdiction_code],
          name: row[:name],
          type: row[:type],
          start_date: row[:start_date],
          end_date: row[:end_date]
        )
      end
    end
  end
end
