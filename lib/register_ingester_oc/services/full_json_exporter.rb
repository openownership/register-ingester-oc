require 'register_ingester_oc/config/adapters'
require 'register_ingester_oc/config/settings'

module RegisterIngesterOc
  module Services
    class FullJsonExporter
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

      def filter_data(src_table_name, dst_table_name, month, dst_s3_prefix)
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
            #{table_name} tab
          WHERE
            tab.mth = '#{month}'
          -- AND
          --  tab.jurisdiction_code = 'gb';
        SQL
      end
    end
  end
end
