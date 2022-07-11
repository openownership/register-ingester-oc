require 'register_ingester_oc/services/file_reader'
require 'register_ingester_oc/companies/reader'

module RegisterIngesterOc
  module Companies
    class FileReader < Services::FileReader
      def initialize(reader: Companies::Reader.new, **kwargs)
        super(reader: reader, **kwargs)
      end
    end
  end
end
