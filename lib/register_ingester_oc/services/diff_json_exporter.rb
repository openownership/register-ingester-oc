require 'register_ingester_oc/config/adapters'
require 'register_ingester_oc/config/settings'

module RegisterIngesterOc
  module Services
    class DiffJsonExporter
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

      def call(dst_table_name, dst_s3_prefix, month, prev_month)
        query = <<~SQL
          CREATE TABLE #{dst_table_name}
          WITH (
            format='JSON',
            write_compression='GZIP',
            external_location = '#{dst_s3_prefix}',
            bucketed_by = ARRAY['company_number'],
            bucket_count = 1
          ) AS
          SELECT
            m202205.*
          FROM
            #{filtered_table_name} m202205
          LEFT JOIN
            #{filtered_table_name} m202204
          ON
            (m202205.company_number = m202204.company_number)
          WHERE
            m202205.mth = '#{month}'
          AND
            m202204.mth = '#{prev_month}'
          AND
          (
            (m202204.name <> m202205.name) OR
            (m202204.company_type <> m202205.company_type) OR
            (m202204.incorporation_date <> m202205.incorporation_date) OR
            (m202204.dissolution_date <> m202205.dissolution_date) OR
            (m202204.restricted_for_marketing <> m202205.restricted_for_marketing) OR
            (m202204."registered_address.in_full" <> m202205."registered_address.in_full")
          );
        SQL
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
