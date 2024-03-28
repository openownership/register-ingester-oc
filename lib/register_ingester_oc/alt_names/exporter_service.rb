# frozen_string_literal: true

require_relative '../config/adapters'
require_relative '../config/settings'
require_relative '../services/exporter_service'

module RegisterIngesterOc
  module AltNames
    class ExporterService < Services::ExporterService
      def initialize(
        athena_adapter: Config::Adapters::ATHENA_ADAPTER,
        athena_database: ENV.fetch('ATHENA_DATABASE'),
        s3_bucket: ENV.fetch('ATHENA_S3_BUCKET'),
        filtered_table_name: ENV.fetch('ALT_NAMES_ATHENA_FILTERED_TABLE_NAME'),
        full_s3_prefix: ENV.fetch('ALT_NAMES_EXPORT_JSON_FULL_S3_PREFIX')
      )
        super(athena_adapter:, athena_database:, s3_bucket:,
              filtered_table_name:, full_s3_prefix:)
      end
    end
  end
end
