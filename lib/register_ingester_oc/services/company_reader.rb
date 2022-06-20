require 'register_sources_oc/structs/company'

require 'register_ingester_oc/utils/gzip_reader'
require 'register_ingester_oc/utils/csv_reader'
require 'register_ingester_oc/utils/json_reader'

module RegisterIngesterOc
  module Services
    class CompanyReader
      def initialize(
        zip_reader: Utils::GzipReader.new,
        csv_reader: Utils::CsvReader.new,
        json_reader: Utils::JsonReader.new
      )
        @zip_reader = zip_reader
        @csv_reader = csv_reader
        @json_reader = json_reader
      end

      def foreach(stream, file_format: 'csv', zipped: true)
        reader = case file_format
          when 'json'
            json_reader
          when 'csv'
            csv_reader
          else
            raise 'unknown_format'
          end

        unzipped_stream(stream, zipped: zipped) do |unzipped|
          reader.foreach(unzipped) do |row|
            yield RegisterSourcesOc::Company.new(
              company_number: row['company_number'],
              jurisdiction_code: row['jurisdiction_code'],
              name: row['name'],
              company_type: row['company_type'],
              incorporation_date: row['incorporation_date'],
              dissolution_date: row['dissolution_date'],
              restricted_for_marketing: row['restricted_for_marketing'],
              registered_address_in_full: row['registered_address.in_full']
            )
          end
        end
      end

      private

      attr_reader :zip_reader, :csv_reader, :json_reader

      def unzipped_stream(stream, zipped: true, &block)
        if zipped
          zip_reader.open_stream(stream, &block)
        else
          block.call stream
        end
      end
    end
  end
end