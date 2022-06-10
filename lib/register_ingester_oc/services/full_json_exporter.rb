require 'register_ingester_oc/config/adapters'
require 'register_ingester_oc/config/settings'

module RegisterIngesterOc
  module Services
    class FullJsonExporter
      def initialize(
        athena_adapter: Config::Adapters::ATHENA_ADAPTER,
        athena_database: ENV.fetch('ATHENA_DATABASE'),
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET'),
        filtered_table_name: ENV.fetch('ATHENA_FILTERED_TABLE_NAME')
      )
        @athena_adapter = athena_adapter
        @athena_database = athena_database
        @s3_bucket = s3_bucket
        @output_location = "s3://#{s3_bucket}/athena_results"
        @filtered_table_name = filtered_table_name
      end

      def call(dst_table_name, dst_s3_prefix, month)
        query = <<~SQL
          CREATE TABLE #{dst_table_name}
          WITH (
            format='JSON',
            write_compression='GZIP',
            external_location = '#{dst_s3_prefix}'
          ) AS
          SELECT
            *
          FROM
            #{filtered_table_name} tab
          WHERE
            tab.mth = '#{month}';
        SQL
        execute_sql query
      end

      private

      attr_reader :athena_adapter, :athena_database, :s3_bucket, :output_location
      attr_reader :filtered_table_name

      def execute_sql(sql_query)
        athena_query = athena_adapter.start_query_execution({
          query_string: sql_query,
          result_configuration: {
            output_location: output_location
          }
        })
        athena_adapter.wait_for_query(athena_query.query_execution_id)
      end
    end
  end
end
