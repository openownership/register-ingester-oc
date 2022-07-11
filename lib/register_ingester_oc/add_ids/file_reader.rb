require 'register_ingester_oc/services/file_reader'
require 'register_ingester_oc/add_ids/reader'

module RegisterIngesterOc
  module AddIds
    class FileReader < Services::FileReader
      def initialize(reader: AddIds::Reader.new, **kwargs)
        super(reader: reader, **kwargs)
      end
    end
  end
end
