require 'bods_sources_oc/structs/company'

require 'register_ingester_oc/utils/gzip_reader'
require 'register_ingester_oc/utils/csv_reader'
require 'register_ingester_oc/utils/json_reader'

module RegisterIngesterOc
  module Services
    class CompanyReader
      def initialize(
        zip_reader: Utils::GzipReader.new,
        csv_reader: Utils::CsvReader.new,
        json_reader: Utils::CsvReader.new
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
            registered_address = RegisteredAddress.new(
              street_address: row['registered_address.street_address'],
              locality: row['registered_address.locality'],
              region: row['registered_address.region'],
              postal_code: row['registered_address.postal_code'],
              country: row['registered_address.country'],
              in_full: row['registered_address.in_full']
            )

            yield Company.new(
              company_number: row['company_number'],
              jurisdiction_code: row['jurisdiction_code'],
              name: row['name'],
              normalised_name: row['normalised_name'],
              company_type: row['company_type'],
              nonprofit: row['nonprofit'],
              current_status: row['current_status'],
              incorporation_date: row['incorporation_date'],
              dissolution_date: row['dissolution_date'],
              branch: row['branch'],
              business_number: row['business_number'],
              current_alternative_legal_name: row['current_alternative_legal_name'],
              current_alternative_legal_name_language: row['current_alternative_legal_name_language'],
              home_jurisdiction_text: row['home_jurisdiction_text'],
              native_company_number: row['native_company_number'],
              previous_names: row['previous_names'],
              alternative_names: row['alternative_names'],
              retrieved_at: row['retrieved_at'],
              registry_url: row['registry_url'],
              restricted_for_marketing: row['restricted_for_marketing'],
              inactive: row['inactive'],
              accounts_next_due: row['accounts_next_due'],
              accounts_reference_date: row['accounts_reference_date'],
              accounts_last_made_up_date: row['accounts_last_made_up_date'],
              annual_return_next_due: row['annual_return_next_due'],
              annual_return_last_made_up_date: row['annual_return_last_made_up_date'],
              has_been_liquidated: row['has_been_liquidated'],
              has_insolvency_history: row['has_insolvency_history'],
              has_charges: row['has_charges'],
              registered_address: registered_address,
              home_jurisdiction_code: row['home_jurisdiction_code'],
              home_jurisdiction_company_number: row['home_jurisdiction_company_number'],
              industry_code_uids: row['industry_code_uids'],
              latest_accounts_date: row['latest_accounts_date'],
              latest_accounts_cash: row['latest_accounts_cash'],
              latest_accounts_assets: row['latest_accounts_assets'],
              latest_accounts_liabilities: row['latest_accounts_liabilities']
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
