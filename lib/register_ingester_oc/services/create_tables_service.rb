# frozen_string_literal: true

require_relative '../config/adapters'
require_relative '../config/settings'

module RegisterIngesterOc
  module Services
    class CreateTablesService
      # rubocop:disable Metrics/ParameterLists
      def initialize(
        raw_table_name:, processed_table_name:, filtered_table_name:,
        bulk_data_s3_prefix:, processed_s3_location:, filtered_s3_location:,
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
        @bulk_data_s3_location = "s3://#{s3_bucket}/#{bulk_data_s3_prefix}"
        @processed_s3_location = processed_s3_location
        @filtered_s3_location = filtered_s3_location
      end
      # rubocop:enable Metrics/ParameterLists

      def call
        create_raw_data_table
        create_processed_table
        create_filtered_table
      end

      private

      attr_reader :athena_adapter, :athena_database, :s3_bucket,
                  :output_location, :raw_table_name, :processed_table_name,
                  :filtered_table_name, :bulk_data_s3_location,
                  :processed_s3_location, :filtered_s3_location

      def create_raw_data_table
        query = <<~SQL
          CREATE EXTERNAL TABLE IF NOT EXISTS #{raw_table_name} (
            #{schemas}
          )
          PARTITIONED BY (`mth` STRING, `part` STRING)
          ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
          WITH SERDEPROPERTIES ("escapeChar"= "¬")
          LOCATION '#{bulk_data_s3_location}';
        SQL
        execute_sql query
      end

      def create_processed_table
        query = <<~SQL
          CREATE EXTERNAL TABLE IF NOT EXISTS `#{processed_table_name}` (
            #{schemas}
          )
          PARTITIONED BY (`mth` STRING, `part` STRING)
          ROW FORMAT SERDE
            'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
          STORED AS INPUTFORMAT
            'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat'
          OUTPUTFORMAT
            'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
          LOCATION '#{processed_s3_location}'
          TBLPROPERTIES (
            'has_encrypted_data'='false',
            'parquet.compression'='GZIP');
        SQL
        execute_sql query
      end

      def execute_sql(sql_query)
        athena_query = athena_adapter.start_query_execution(
          {
            query_string: sql_query,
            result_configuration: {
              output_location:
            }
          }
        )
        athena_adapter.wait_for_query(athena_query.query_execution_id)
      end
    end
  end
end
