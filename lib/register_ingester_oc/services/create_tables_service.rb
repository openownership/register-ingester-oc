require 'register_ingester_oc/config/adapters'
require 'register_ingester_oc/config/settings'

module RegisterIngesterOc
  module Services
    class CreateTablesService
      def initialize(
        athena_adapter: Config::Adapters::ATHENA_ADAPTER,
        athena_database: ENV.fetch('ATHENA_DATABASE'),
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET'),
        raw_table_name: ENV.fetch('ATHENA_RAW_TABLE_NAME'),
        processed_table_name: ENV.fetch('ATHENA_PROCESSED_TABLE_NAME'),
        filtered_table_name: ENV.fetch('ATHENA_FILTERED_TABLE_NAME'),
        bulk_data_s3_prefix: ENV.fetch('BULK_DATA_S3_PREFIX'),
        processed_s3_location: ENV.fetch('PROCESSED_S3_LOCATION'),
        filtered_s3_location: ENV.fetch('FILTERED_S3_LOCATION')
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

      def call
        create_raw_data_table
        create_processed_table
        create_filtered_table
      end

      private

      attr_reader :athena_adapter, :athena_database, :s3_bucket, :output_location
      attr_reader :raw_table_name, :processed_table_name, :filtered_table_name
      attr_reader :bulk_data_s3_location, :processed_s3_location, :filtered_s3_location

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
            `registered_address.in_full` STRING
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

      def execute_sql(sql_query)
        athena_query = athena_adapter.start_query_execution({
          query_string: sql_query,
          result_configuration: {
            output_location: output_location
          }
        })
        athena_adapter.wait_for_query(athena_query.query_execution_id)
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
          alternative_names STRING,
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
