require 'register_ingester_oc/services/oc_splitter_service'

RSpec.describe RegisterIngesterOc::Services::OcSplitterService do
  subject do
    described_class.new(
      s3_adapter: s3_adapter,
      file_splitter_service: file_splitter_service,
      gzip_reader: gzip_reader
    )
  end

  let(:s3_adapter) { double 's3_adapter' }
  let(:file_splitter_service) { double 'file_splitter_service' }
  let(:gzip_reader) { double 'gzip_reader' }

  describe '#split_file' do
    it 'splits and uploads compressed chunks of file' do
      stream = double 'stream'
      s3_bucket = 'some_bucket'
      s3_prefix = 'some/prefix'
      split_size = 5
      max_lines = 20

      unzipped_stream = double 'unzipped_stream'
      expect(gzip_reader).to receive(:open_stream).with(stream).and_yield unzipped_stream

      file1 = 'file1'
      file2 = 'file2'
      file3 = 'file3'
      expect(file_splitter_service).to receive(:split_stream).with(
        unzipped_stream,
        split_size: split_size,
        max_lines: max_lines
      ).and_yield(file1).and_yield(file2).and_yield(file3)

      allow(s3_adapter).to receive(:upload_to_s3)

      # make the call
      subject.split_file(stream, s3_bucket: s3_bucket, s3_prefix: s3_prefix, split_size: split_size, max_lines: max_lines)

      [
        [file1, 'some/prefix/part=part0/file-0.csv.gz'],
        [file2, 'some/prefix/part=part1/file-1.csv.gz'],
        [file3, 'some/prefix/part=part2/file-2.csv.gz']
      ].each do |local_path, expected_s3_path|
        expect(s3_adapter).to have_received(:upload_to_s3).with(
          s3_bucket: s3_bucket, s3_path: expected_s3_path, local_path: local_path)
      end
    end
  end
end
