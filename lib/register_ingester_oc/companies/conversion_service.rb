require 'register_ingester_oc/config/adapters'
require 'register_ingester_oc/config/settings'

module RegisterIngesterOc
  module Companies
    class ConversionService
      DEFAULT_JURISDICTION_CODES = ['gb', 'dk', 'sk']

      def initialize(
        athena_adapter: Config::Adapters::ATHENA_ADAPTER,
        athena_database: ENV.fetch('ATHENA_DATABASE'),
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET'),
        raw_table_name: ENV.fetch('COMPANIES_ATHENA_RAW_TABLE_NAME'),
        processed_table_name: ENV.fetch('COMPANIES_ATHENA_PROCESSED_TABLE_NAME'),
        filtered_table_name: ENV.fetch('COMPANIES_ATHENA_FILTERED_TABLE_NAME')
      )
        @athena_adapter = athena_adapter
        @athena_database = athena_database
        @s3_bucket = s3_bucket
        @output_location = "s3://#{s3_bucket}/athena_results"
        @raw_table_name = raw_table_name
        @processed_table_name = processed_table_name
        @filtered_table_name = filtered_table_name
      end

      def call(month, jurisdiction_codes: DEFAULT_JURISDICTION_CODES)
        # Detect partitions (eg our new months data)
        discover_partitions(raw_table_name)

        # Perform bulk transformation step
        insert_new_data(raw_table_name, processed_table_name, month)

        # Create filtered data
        filter_data(processed_table_name, filtered_table_name, month, jurisdiction_codes)
      end

      private

      attr_reader :athena_adapter, :athena_database, :s3_bucket, :output_location
      attr_reader :raw_table_name, :processed_table_name, :filtered_table_name

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

      def filter_data(src_table_name, dst_table_name, month, jurisdiction_codes)
        jurisdiction_codes_list = jurisdiction_codes.map { |code| "'#{code}'" }.join(", ")

        query = <<~SQL
          INSERT INTO #{dst_table_name}
          SELECT
            company_number,
            name,
            company_type,
            incorporation_date,
            dissolution_date,
            CASE lower(restricted_for_marketing)
              WHEN 'true' THEN TRUE
              WHEN 't' THEN TRUE
              WHEN 'false' THEN FALSE
              WHEN 'f' THEN FALSE
              ELSE NULL
            END AS restricted_for_marketing,
            "registered_address.country",
            "registered_address.in_full",
            mth,
            jurisdiction_code
          FROM #{src_table_name}
          WHERE mth = '#{month}' AND jurisdiction_code IN (#{jurisdiction_codes_list});
        SQL

        execute_sql query
      end

      def execute_sql(sql_query)
        athena_adapter.execute_and_wait(sql_query, output_location)
      end
    end
  end
end