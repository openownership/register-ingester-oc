require 'register_ingester_oc/services/file_reader'
require 'register_ingester_oc/alt_names/reader'

module RegisterIngesterOc
  module AltNames
    class FileReader < Services::FileReader
      def initialize(reader: AltNames::Reader.new, **kwargs)
        super(reader: reader, **kwargs)
      end
    end
  end
end
