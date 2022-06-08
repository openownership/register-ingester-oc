require 'register_ingester_oc/config/adapters'
require 'register_ingester_oc/config/settings'

module RegisterIngesterOc
  module Services
    class DiffJsonExporter
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

      def filter_data(src_table_name, dst_table_name, month, prev_month, dst_s3_prefix)
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
            #{src_table_name} m202205
          LEFT JOIN
            #{src_table_name} m202204
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
    end
  end
end
