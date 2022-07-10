require 'register_ingester_oc/utils/csv_reader'
require 'register_ingester_oc/utils/json_reader'
require 'register_ingester_oc/utils/gzip_reader'

require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/object/blank'

module RegisterIngesterOc
  module Utils
    class GenericReader
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
        reader = select_reader file_format

        unzipped_stream(stream, zipped: zipped) do |unzipped|
          reader.foreach(unzipped) do |row|
            yield process_row(row.with_indifferent_access)
          end
        end
      end

      private

      attr_reader :zip_reader, :csv_reader, :json_reader

      def process_row(row)
        raise 'implement'
      end

      def select_reader(file_format)
        reader = case file_format
        when 'json'
          json_reader
        when 'csv'
          csv_reader
        else
          raise 'unknown_format'
        end
      end

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
