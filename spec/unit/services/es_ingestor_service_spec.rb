# frozen_string_literal: true

require 'register_ingester_oc/services/es_ingestor_service'

RSpec.describe RegisterIngesterOc::Services::EsIngestorService do
  subject do
    described_class.new(
      row_processor:,
      file_reader:,
      repository:,
      s3_adapter:,
      s3_bucket:,
      full_s3_prefix:
    )
  end

  let(:row_processor) { double 'row_processor' }
  let(:file_reader) { double 'file_reader' }
  let(:repository) { double 'repository' }
  let(:s3_adapter) { double 's3_adapter' }
  let(:s3_bucket) { double 's3_bucket' }
  let(:full_s3_prefix) { 's3_prefix/more_prefix' }

  it 'ingests files from s3 into ES' do
    s3_paths = ['s3_prefix/more_prefix/mth=2022_07/path1', 's3_prefix/more_prefix/mth=2022_07/path2']
    expect(s3_adapter).to receive(:list_objects).with(
      s3_bucket:,
      s3_prefix: 's3_prefix/more_prefix/mth=2022_07'
    ).and_return s3_paths

    record1 = double 'record1'
    mapped_record1 = double 'mapped_record1'
    expect(file_reader).to receive(:read_from_s3).with(
      s3_bucket:,
      s3_path: s3_paths[0],
      file_format: RegisterCommon::Parsers::FileFormats::JSON,
      compression: RegisterCommon::Decompressors::CompressionTypes::GZIP
    ).and_yield [record1]
    expect(row_processor).to receive(:process_row).with(record1).and_return mapped_record1

    record2 = double 'record2'
    mapped_record2 = double 'mapped_record2'
    expect(file_reader).to receive(:read_from_s3).with(
      s3_bucket:,
      s3_path: s3_paths[1],
      file_format: RegisterCommon::Parsers::FileFormats::JSON,
      compression: RegisterCommon::Decompressors::CompressionTypes::GZIP
    ).and_yield [record2]
    expect(row_processor).to receive(:process_row).with(record2).and_return mapped_record2

    expect(repository).to receive(:store).with([mapped_record1])
    expect(repository).to receive(:store).with([mapped_record2])

    subject.call '2022_07'
  end
end
