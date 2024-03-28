# frozen_string_literal: true

require_relative '../config/adapters'
require_relative '../config/settings'
require_relative '../services/create_tables_service'

module RegisterIngesterOc
  module AltNames
    class CreateTablesService < Services::CreateTablesService
      # rubocop:disable Metrics/ParameterLists
      def initialize(
        athena_adapter: Config::Adapters::ATHENA_ADAPTER,
        athena_database: ENV.fetch('ATHENA_DATABASE'),
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET'),
        raw_table_name: ENV.fetch('ALT_NAMES_ATHENA_RAW_TABLE_NAME'),
        processed_table_name: ENV.fetch('ALT_NAMES_ATHENA_PROCESSED_TABLE_NAME'),
        filtered_table_name: ENV.fetch('ALT_NAMES_ATHENA_FILTERED_TABLE_NAME'),
        bulk_data_s3_prefix: ENV.fetch('ALT_NAMES_BULK_DATA_S3_PREFIX'),
        processed_s3_location: ENV.fetch('ALT_NAMES_PROCESSED_S3_LOCATION'),
        filtered_s3_location: ENV.fetch('ALT_NAMES_FILTERED_S3_LOCATION')
      )
        super(athena_adapter:, athena_database:, s3_bucket:, raw_table_name:,
              processed_table_name:, filtered_table_name:, bulk_data_s3_prefix:,
              processed_s3_location:, filtered_s3_location:)
      end
      # rubocop:enable Metrics/ParameterLists

      private

      def create_filtered_table
        query = <<~SQL
          CREATE EXTERNAL TABLE IF NOT EXISTS `#{filtered_table_name}` (
            company_number STRING,
            name STRING,
            type STRING,
            start_date STRING,
            end_date STRING
          )
          PARTITIONED BY (`mth` STRING, `jurisdiction_code` STRING)
          ROW FORMAT SERDE
            'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
          STORED AS INPUTFORMAT
            'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat'
          OUTPUTFORMAT
            'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
          LOCATION '#{filtered_s3_location}'
          TBLPROPERTIES (
            'has_encrypted_data'='false',
            'parquet.compression'='GZIP');
        SQL
        execute_sql query
      end

      def schemas
        <<~SQL
          company_number STRING,
          jurisdiction_code STRING,
          name STRING,
          type STRING,
          start_date STRING,
          end_date STRING
        SQL
      end
    end
  end
end
