require 'register_ingester_oc/config/settings'
require 'register_ingester_oc/config/elasticsearch'

module RegisterIngesterOc
  module Services
    class EsIndexUpdater
      def initialize(client: Config::ELASTICSEARCH_CLIENT)
        @client = client
      end

      def create_index
        client.indices.create index: 'companies', body: { mappings: mappings }
      end

      def put_index
        client.indices.put_mapping index: 'companies', type: 'company', body: {
          company: mappings
        }
      end

      private

      attr_reader :client

      def mappings
        {
          properties: {
            "company_number": {
              "type": "keyword"
            },
            "jurisdiction_code": {
              "type": "keyword"
            },
            "name": {
              "type": "text",
              "fields": {
                "raw": { 
                  "type":  "keyword"
                }
              }
            },
            "company_type": {
              "type": "keyword"
            },
            "incorporation_date": {
              "type": "keyword"
            },
            "dissolution_date": {
              "type": "keyword"
            },
            "restricted_for_marketing": {
              "type": "boolean"
            },
            "registered_address_in_full": {
              "type": "text",
              "fields": {
                "raw": { 
                  "type":  "keyword"
                }
              }
            },
            "registered_address_country": {
              "type": "keyword"
            },
          }
        }
      end
    end
  end
end
