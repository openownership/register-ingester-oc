require 'register_ingester_oc/config/adapters'
require 'register_ingester_oc/config/settings'

module RegisterIngesterOc
  module AltNames
    class CreateTablesService
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

      attr_reader :athena_adapter, :athena_database, :s3_bucket, :output_location, :raw_table_name, :processed_table_name, :filtered_table_name, :bulk_data_s3_location, :processed_s3_location, :filtered_s3_location

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
          ROW FORMAT SERDE#{' '}
            'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'#{' '}
          STORED AS INPUTFORMAT#{' '}
            'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat'#{' '}
          OUTPUTFORMAT#{' '}
            'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
          LOCATION '#{processed_s3_location}'
          TBLPROPERTIES (
            'has_encrypted_data'='false',#{' '}
            'parquet.compression'='GZIP');
        SQL
        execute_sql query
      end

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
          ROW FORMAT SERDE#{' '}
            'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'#{' '}
          STORED AS INPUTFORMAT#{' '}
            'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat'#{' '}
          OUTPUTFORMAT#{' '}
            'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
          LOCATION '#{filtered_s3_location}'
          TBLPROPERTIES (
            'has_encrypted_data'='false',#{' '}
            'parquet.compression'='GZIP');
        SQL
        execute_sql query
      end

      def execute_sql(sql_query)
        athena_query = athena_adapter.start_query_execution(
          {
            query_string: sql_query,
            result_configuration: {
              output_location:,
            },
          },
        )
        athena_adapter.wait_for_query(athena_query.query_execution_id)
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
