require 'register_ingester_oc/alt_names/file_reader'

RSpec.describe RegisterIngesterOc::AltNames::FileReader do
  subject { described_class.new(reader: reader, s3_adapter: s3_adapter, batch_size: batch_size) }

  let(:reader) { double 'reader' }
  let(:s3_adapter) { double 's3_adapter' }
  let(:batch_size) { 2 }

  describe '#import_from_s3' do
    it 'downloads s3 file and yields batched rows' do
      s3_bucket = double 's3_bucket'
      s3_path = double 's3_path'
      file_format = double 'file_format'
      zipped = double 'zipped'

      tmpdir = '/tmp/fake_tmp_dir'
      file_path = File.join(tmpdir, "tmpfile")

      expect(Dir).to receive(:mktmpdir).and_yield tmpdir
      expect(s3_adapter).to receive(:download_from_s3).with(
        s3_bucket: s3_bucket,
        s3_path: s3_path,
        local_path: file_path
      )

      stream = double 'stream'
      expect(File).to receive(:open).with(file_path, 'r').and_yield stream

      record1 = double 'record1'
      record2 = double 'record2'
      record3 = double 'record3'
      expect(reader).to receive(:foreach).with(
        stream,
        file_format: file_format,
        zipped: zipped
      ).and_yield(record1).and_yield(record2).and_yield(record3)

      # perform call
      results = []
      subject.import_from_s3(
        s3_bucket: s3_bucket, s3_path: s3_path, file_format: file_format, zipped: zipped
      ) do |batch_records|
        results << batch_records
      end

      expect(results).to eq [[record1, record2], [record3]]
    end
  end

  describe '#import_from_local_path' do
    it 'streams file and yields batched rows' do
      file_format = double 'file_format'
      zipped = double 'zipped'
      tmpdir = '/tmp/fake_tmp_dir'
      file_path = File.join(tmpdir, "tmpfile")

      stream = double 'stream'
      expect(File).to receive(:open).with(file_path, 'r').and_yield stream

      record1 = double 'record1'
      record2 = double 'record2'
      record3 = double 'record3'
      expect(reader).to receive(:foreach).with(
        stream,
        file_format: file_format,
        zipped: zipped
      ).and_yield(record1).and_yield(record2).and_yield(record3)

      # perform call
      results = []
      subject.import_from_local_path(
        file_path, file_format: file_format, zipped: zipped
      ) do |batch_records|
        results << batch_records
      end

      expect(results).to eq [[record1, record2], [record3]]
    end
  end

  describe '#import_from_stream' do
    it 'processes streams and yields batched rows' do
      file_format = double 'file_format'
      zipped = double 'zipped'
      stream = double 'stream'

      record1 = double 'record1'
      record2 = double 'record2'
      record3 = double 'record3'
      expect(reader).to receive(:foreach).with(
        stream,
        file_format: file_format,
        zipped: zipped
      ).and_yield(record1).and_yield(record2).and_yield(record3)

      # perform call
      results = []
      subject.import_from_stream(
        stream, file_format: file_format, zipped: zipped
      ) do |batch_records|
        results << batch_records
      end

      expect(results).to eq [[record1, record2], [record3]]
    end
  end
end
