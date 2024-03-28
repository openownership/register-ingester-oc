# frozen_string_literal: true

require_relative '../config/adapters'
require_relative '../config/settings'
require_relative '../services/create_tables_service'

module RegisterIngesterOc
  module Companies
    class CreateTablesService < Services::CreateTablesService
      # rubocop:disable Metrics/ParameterLists
      def initialize(
        athena_adapter: Config::Adapters::ATHENA_ADAPTER,
        athena_database: ENV.fetch('ATHENA_DATABASE'),
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET'),
        raw_table_name: ENV.fetch('COMPANIES_ATHENA_RAW_TABLE_NAME'),
        processed_table_name: ENV.fetch('COMPANIES_ATHENA_PROCESSED_TABLE_NAME'),
        filtered_table_name: ENV.fetch('COMPANIES_ATHENA_FILTERED_TABLE_NAME'),
        bulk_data_s3_prefix: ENV.fetch('COMPANIES_BULK_DATA_S3_PREFIX'),
        processed_s3_location: ENV.fetch('COMPANIES_PROCESSED_S3_LOCATION'),
        filtered_s3_location: ENV.fetch('COMPANIES_FILTERED_S3_LOCATION')
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
            company_type STRING,
            incorporation_date STRING,
            dissolution_date STRING,
            restricted_for_marketing BOOLEAN,
            `registered_address.country` STRING,
            `registered_address.in_full` STRING,
            industry_code_uids ARRAY<STRING>
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
          normalised_name STRING,
          company_type STRING,
          nonprofit STRING,
          current_status STRING,
          incorporation_date STRING,
          dissolution_date STRING,
          branch STRING,
          business_number STRING,
          current_alternative_legal_name STRING,
          current_alternative_legal_name_language STRING,
          home_jurisdiction_text STRING,
          native_company_number STRING,
          previous_names STRING,
          retrieved_at STRING,
          registry_url STRING,
          restricted_for_marketing STRING,
          inactive STRING,
          accounts_next_due STRING,
          accounts_reference_date STRING,
          accounts_last_made_up_date STRING,
          annual_return_next_due STRING,
          annual_return_last_made_up_date STRING,
          has_been_liquidated STRING,
          has_insolvency_history STRING,
          has_charges STRING,
          number_of_employees STRING,
          `registered_address.street_address` STRING,
          `registered_address.locality` STRING,
          `registered_address.region` STRING,
          `registered_address.postal_code` STRING,
          `registered_address.country` STRING,
          `registered_address.in_full` STRING,
          home_jurisdiction_code STRING,
          home_jurisdiction_company_number STRING,
          industry_code_uids STRING,
          latest_accounts_date STRING,
          latest_accounts_cash STRING,
          latest_accounts_assets STRING,
          latest_accounts_liabilities STRING
        SQL
      end
    end
  end
end
