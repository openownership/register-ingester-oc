# frozen_string_literal: true

require_relative '../config/adapters'
require_relative '../config/settings'
require_relative '../services/conversion_service'

module RegisterIngesterOc
  module AltNames
    class ConversionService < Services::ConversionService
      # rubocop:disable Metrics/ParameterLists
      def initialize(
        athena_adapter: Config::Adapters::ATHENA_ADAPTER,
        athena_database: ENV.fetch('ATHENA_DATABASE'),
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET'),
        raw_table_name: ENV.fetch('ALT_NAMES_ATHENA_RAW_TABLE_NAME'),
        processed_table_name: ENV.fetch('ALT_NAMES_ATHENA_PROCESSED_TABLE_NAME'),
        filtered_table_name: ENV.fetch('ALT_NAMES_ATHENA_FILTERED_TABLE_NAME')
      )
        super(athena_adapter:, athena_database:, s3_bucket:, raw_table_name:,
              processed_table_name:, filtered_table_name:)
      end
      # rubocop:enable Metrics/ParameterLists

      private

      def filter_data(src_table_name, dst_table_name, month, jurisdiction_codes)
        jurisdiction_codes_list = jurisdiction_codes.map { |code| "'#{code}'" }.join(', ')

        query = <<~SQL
          INSERT INTO #{dst_table_name}
          SELECT
            company_number,
            name,
            type,
            start_date,
            end_date,
            mth,
            jurisdiction_code
          FROM #{src_table_name}
          WHERE mth = '#{month}' AND jurisdiction_code IN (#{jurisdiction_codes_list});
        SQL

        execute_sql query
      end
    end
  end
end
