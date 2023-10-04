# frozen_string_literal: true

require_relative '../config/adapters'
require_relative '../config/settings'

module RegisterIngesterOc
  module AddIds
    class ExporterService
      def initialize(
        athena_adapter: Config::Adapters::ATHENA_ADAPTER,
        athena_database: ENV.fetch('ATHENA_DATABASE'),
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET'),
        filtered_table_name: ENV.fetch('ADD_IDS_ATHENA_FILTERED_TABLE_NAME'),
        full_s3_prefix: ENV.fetch('ADD_IDS_EXPORT_JSON_FULL_S3_PREFIX')
      )
        @athena_adapter = athena_adapter
        @athena_database = athena_database
        @s3_bucket = s3_bucket
        @output_location = "s3://#{s3_bucket}/athena_results"
        @filtered_table_name = filtered_table_name
        @full_s3_prefix = full_s3_prefix
      end

      def call(month)
        export_all_json month
      end

      def s3_export_location_full(month)
        "#{File.join("s3://#{s3_bucket}", full_s3_prefix, "mth=#{month}")}/"
      end

      private

      attr_reader :athena_adapter, :athena_database, :s3_bucket, :output_location, :filtered_table_name, :full_s3_prefix

      def export_all_json(month)
        dst_table_name = "oc_export_full_#{month}"
        dst_s3_location = s3_export_location_full(month)

        query = <<~SQL
          DROP TABLE IF EXISTS #{dst_table_name}
        SQL
        execute_sql query

        query = <<~SQL
          CREATE TABLE #{dst_table_name}
          WITH (
            format='JSON',
            write_compression='GZIP',
            external_location = '#{dst_s3_location}'
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
