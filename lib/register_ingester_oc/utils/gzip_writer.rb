require 'zlib'

module RegisterIngesterOc
  module Utils
    class GzipWriter
      def open_file(local_path)
        Zlib::GzipWriter.open(local_path)
      end

      def open_stream(stream)
        Zlib::GzipWriter.new(stream)
      end

      def close_file(gz_file)
        gz_file.close
      end

      def close_stream(gz_stream)
        gz_stream.close.string
      end
    end
  end
end
