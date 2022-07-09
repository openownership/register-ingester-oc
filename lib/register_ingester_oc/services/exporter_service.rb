require 'register_ingester_oc/config/adapters'
require 'register_ingester_oc/config/settings'

module RegisterIngesterOc
  module Services
    class ExporterService
      def initialize(
        athena_adapter: Config::Adapters::ATHENA_ADAPTER,
        athena_database: ENV.fetch('ATHENA_DATABASE'),
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET'),
        filtered_table_name: ENV.fetch('ATHENA_FILTERED_TABLE_NAME'),
        full_s3_prefix: ENV.fetch('EXPORT_JSON_FULL_S3_PREFIX'),
        diffs_s3_prefix: ENV.fetch('EXPORT_JSON_DIFFS_S3_PREFIX')
      )
        @athena_adapter = athena_adapter
        @athena_database = athena_database
        @s3_bucket = s3_bucket
        @output_location = "s3://#{s3_bucket}/athena_results"
        @filtered_table_name = filtered_table_name
        @full_s3_prefix = full_s3_prefix
        @diffs_s3_prefix = diffs_s3_prefix
      end

      def call(month)
        calc_prev_month month

        export_all_json month
        export_json_diffs month
      end

      def s3_export_location_full(month)
        File.join("s3://#{s3_bucket}", full_s3_prefix, "mth=#{month}") + '/'
      end

      def s3_export_location_diffs(month)
        File.join("s3://#{s3_bucket}", diffs_s3_prefix, "mth=#{month}") + '/'
      end

      private

      attr_reader :athena_adapter, :athena_database, :s3_bucket, :output_location
      attr_reader :filtered_table_name, :full_s3_prefix, :diffs_s3_prefix

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

      def export_json_diffs(month)
        dst_table_name = "oc_export_diff_#{month}"
        dst_s3_location = s3_export_location_diffs(month)
        prev_month = calc_prev_month month

        query = <<~SQL
          DROP TABLE IF EXISTS #{dst_table_name}
        SQL
        execute_sql query

        query = <<~SQL
          CREATE TABLE #{dst_table_name}
          WITH (
            format='JSON',
            write_compression='GZIP',
            external_location = '#{dst_s3_location}',
            bucketed_by = ARRAY['company_number'],
            bucket_count = 1
          ) AS
          SELECT
            current.*
          FROM
            #{filtered_table_name} current
          LEFT JOIN
            #{filtered_table_name} prev
          ON
            (current.company_number = prev.company_number)
          WHERE
            current.mth = '#{month}'
          AND
            prev.mth = '#{prev_month}'
          AND
          (
            (prev.name <> current.name) OR
            (prev.company_type <> current.company_type) OR
            (prev.incorporation_date <> current.incorporation_date) OR
            (prev.dissolution_date <> current.dissolution_date) OR
            (prev.restricted_for_marketing <> current.restricted_for_marketing) OR
            (prev."registered_address.in_full" <> current."registered_address.in_full") OR
            (prev."registered_address.country" <> current."registered_address.country")
          );
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

      def calc_prev_month(month)
        month_split = month.split('_', 2).map(&:to_i)
        if month_split.length != 2
          raise 'wrong month format'
        end
        
        year_i = month_split[0].to_i
        month_i = month_split[1].to_i

        prev_year_i = (month_i == 1) ? (year_i-1) : year_i
        prev_month_i = (month_i == 1) ? 12 : (month_i-1)

        "%d_%02d" % [prev_year_i, prev_month_i]
      end
    end
  end
end
