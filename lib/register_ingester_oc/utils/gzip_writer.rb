require 'zlib'

module RegisterIngesterOc
  module Utils
    class GzipWriter
      def open_file(local_path)
        Zlib::GzipWriter.open(local_path)
      end

      def close_file(gz_file)
        gz_file.close
      end
    end
  end
end
