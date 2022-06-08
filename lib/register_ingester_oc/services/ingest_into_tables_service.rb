require 'register_ingester_oc/config/adapters'
require 'register_ingester_oc/config/settings'

module RegisterIngesterOc
  module Services
    class IngestIntoTablesService
      def initialize(
        athena_adapter: Config::Adapters::ATHENA_ADAPTER,
        athena_database: ENV.fetch('ATHENA_DATABASE'),
        athena_table: ENV.fetch('ATHENA_TABLE_NAME'),
        s3_bucket:,
        s3_prefix:
      )
        @athena_adapter = athena_adapter
        @athena_database = athena_database
        @athena_table = athena_table
        @s3_bucket = s3_bucket
        @s3_prefix = s3_prefix
        @output_location = "s3://#{s3_bucket}/athena_results"
      end

      def call(month, s3_prefix)
        
      end

      private

      attr_reader :athena_adapter, :athena_database, :athena_table, :s3_bucket, :s3_prefix, :output_location

      def create_raw_data_table(table_name, s3_prefix)
        query = <<~SQL
          CREATE EXTERNAL TABLE #{table_name} (
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
          )
            PARTITIONED BY (`mth` STRING, `part` STRING)
            ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
            LOCATION '#{s3_prefix}';
          -- TBLPROPERTIES ("skip.header.line.count"="1");
        SQL
      end

      def destroy_raw_data_table(table_name, s3_prefix)
        query = <<~SQL
          DROP TABLE `#{table_name}`
        SQL
      end

      def discover_partitions(table_name)
        query = <<~SQL
          MSCK REPAIR TABLE #{table_name}
        SQL
      end

      def create_processed_table(table_name, s3_prefix)
        query = <<~SQL
          CREATE EXTERNAL TABLE IF NOT EXISTS `#{table_name}` (
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
          )
          PARTITIONED BY (`mth` STRING, `part` STRING)
          ROW FORMAT SERDE 
            'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe' 
          STORED AS INPUTFORMAT 
            'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat' 
          OUTPUTFORMAT 
            'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
          LOCATION '#{s3_prefix}'
          TBLPROPERTIES (
            'has_encrypted_data'='false', 
            'parquet.compression'='GZIP');
        SQL
      end

      def insert_new_data(src_table_name, dst_table_name, month)
        query = <<~SQL
          INSERT INTO #{dst_table_name}
          SELECT * FROM #{src_table_name}
          WHERE mth = '#{month}';
        SQL
      end

      def create_filtered_table(table_name, s3_prefix)
        query = <<~SQL
          CREATE EXTERNAL TABLE `#{table_name}` (
            company_number STRING,
            name STRING,
            company_type STRING,
            incorporation_date STRING,
            dissolution_date STRING,
            restricted_for_marketing STRING,
            `registered_address.in_full` STRING
          )
          PARTITIONED BY (`mth` STRING, `jurisdiction_code` STRING)
          ROW FORMAT SERDE 
            'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe' 
          STORED AS INPUTFORMAT 
            'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat' 
          OUTPUTFORMAT 
            'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
          LOCATION '#{s3_prefix}'
          TBLPROPERTIES (
            'has_encrypted_data'='false', 
            'parquet.compression'='GZIP');
        SQL
      end

      def filter_data(src_table_name, dst_table_name, month, jurisdiction_codes: ['gb'])
        jurisdiction_codes_list = jurisdiction_codes.map { |code| "'#{code}'" }.join(", ")

        query = <<~SQL
          INSERT INTO #{dst_table_name}
          SELECT
            company_number,
            name,
            company_type,
            incorporation_date,
            dissolution_date,
            restricted_for_marketing,
            "registered_address.in_full",
            mth,
            jurisdiction_code
          FROM #{src_table_name}
          WHERE mth = '#{month}' AND jurisdiction_code IN (#{jurisdiction_codes_list});
        SQL
      end
    end
  end
end
