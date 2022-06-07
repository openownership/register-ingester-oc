require 'tmpdir'
require 'register_ingester_oc/utils/gzip_writer'

module RegisterIngesterOc
  module Services
    class FileSplitterService
      DEFAULT_LINES_PER_FILE = 2_500_000

      def initialize(writer: Utils::GzipWriter.new)
        @writer = writer
      end

      def split_stream(stream, max_lines: DEFAULT_LINES_PER_FILE)
        file_index = 0

        Dir.mktmpdir do |dir|
          file_path = File.join(dir, "file-#{file_index}")
          current_file = writer.open_file(file_path)
          current_row_count = 0

          stream.each do |line|
            # Write line to open file
            current_file << line

            # Increment row count
            current_row_count += 1

            # Check whether our target of lines is met
            next unless current_row_count >= max_lines

            # Since line count target exceeded close file and yield to user
            writer.close_file(current_file)
            yield file_path

            # Open new file ready for next lines
            file_index += 1
            file_path = File.join(dir, "file-#{file_index}")
            current_file = writer.open_file(file_path)
            current_row_count = 0
          end

          writer.close_file(current_file)
          if current_row_count >= max_lines
            yield file_path
            file_index += 1
          end
        end

        file_index
      end

      private

      attr_reader :writer
    end
  end
end
