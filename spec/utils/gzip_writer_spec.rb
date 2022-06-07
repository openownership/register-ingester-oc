require 'tmpdir'
require 'register_ingester_oc/utils/gzip_reader'
require 'register_ingester_oc/utils/gzip_writer'

RSpec.describe RegisterIngesterOc::Utils::GzipWriter do
  subject { described_class.new }

  let(:gzip_reader) { RegisterIngesterOc::Utils::GzipReader.new }

  it 'writes a gzip to desired path successfully' do
    Dir.mktmpdir do |tmpdir|
      file_path = File.join(tmpdir, 'test_file')
      content = "SOME CONTENT\nFOR THE FILE\n"

      # Use gzip writer to write our content to the file path
      begin
        file = subject.open_file file_path
        file << content
      ensure
        subject.close_file file
      end

      # Unzip using our gzip reader
      result = File.open(file_path) do |stream|
        gzip_reader.open_stream(stream) { |unzipped| unzipped.read }
      end

      # Check the unzipped content matches our original content
      expect(result).to eq content
    end
  end
end
