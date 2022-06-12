require 'json'

module RegisterIngesterOc
  module Utils
    class JsonReader
      def foreach(stream, headers: true, &block)
        stream.each { |line| yield JSON.parse(line) }
      end
    end
  end
end
