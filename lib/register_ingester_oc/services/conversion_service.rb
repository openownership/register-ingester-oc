# frozen_string_literal: true

require_relative '../config/adapters'
require_relative '../config/settings'

module RegisterIngesterOc
  module Services
    class ConversionService
      DEFAULT_JURISDICTION_CODES = %w[gb dk sk].freeze

      # rubocop:disable Metrics/ParameterLists
      def initialize(
        raw_table_name:, processed_table_name:, filtered_table_name:,
        athena_adapter: Config::Adapters::ATHENA_ADAPTER,
        athena_database: ENV.fetch('ATHENA_DATABASE'),
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET')
      )
        @athena_adapter = athena_adapter
        @athena_database = athena_database
        @s3_bucket = s3_bucket
        @output_location = "s3://#{s3_bucket}/athena_results"
        @raw_table_name = raw_table_name
        @processed_table_name = processed_table_name
        @filtered_table_name = filtered_table_name
      end
      # rubocop:enable Metrics/ParameterLists

      def call(month, jurisdiction_codes: DEFAULT_JURISDICTION_CODES)
        # Detect partitions (eg our new months data)
        discover_partitions(raw_table_name)

        # Perform bulk transformation step
        insert_new_data(raw_table_name, processed_table_name, month)

        # Create filtered data
        filter_data(processed_table_name, filtered_table_name, month, jurisdiction_codes)
      end

      private

      attr_reader :athena_adapter, :athena_database, :s3_bucket, :output_location, :raw_table_name,
                  :processed_table_name, :filtered_table_name

      def discover_partitions(table_name)
        query = <<~SQL
          MSCK REPAIR TABLE #{table_name}
        SQL
        execute_sql query
      end

      def insert_new_data(src_table_name, dst_table_name, month)
        query = <<~SQL
          INSERT INTO #{dst_table_name}
          SELECT * FROM #{src_table_name}
          WHERE mth = '#{month}';
        SQL
        execute_sql query
      end

      def execute_sql(sql_query)
        athena_adapter.execute_and_wait(sql_query, output_location)
      end
    end
  end
end
