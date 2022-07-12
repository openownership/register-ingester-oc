require 'register_ingester_oc/apps/bulk_data_splitter'

RSpec.describe RegisterIngesterOc::Apps::BulkDataSplitter do
  subject do
    described_class.new(
      s3_bucket: s3_bucket,
      splitter_service: splitter_service,
      split_size: split_size,
      max_lines: max_lines,
      companies_s3_prefix: companies_s3_prefix,
      alt_names_s3_prefix: alt_names_s3_prefix,
      add_ids_s3_prefix: add_ids_s3_prefix
    )
  end

  let(:s3_bucket) { double 's3_bucket' }
  let(:companies_s3_prefix) { 'example/companies_s3_prefix' }
  let(:alt_names_s3_prefix) { 'example/alt_names_s3_prefix' }
  let(:add_ids_s3_prefix) { 'example/add_ids_s3_prefix' }
  let(:splitter_service) { double 'splitter_service' }
  let(:split_size) { double 'split_size' }
  let(:max_lines) { double 'max_lines' }

  let(:oc_source) { 'companies' }
  let(:month) { '2022_05' }
  let(:local_path) { 'local_path' }

  describe '#call' do
    let(:stream) { double 'stream' }

    before do
      allow(File).to receive(:open).with(local_path, 'rb').and_yield stream
      allow(splitter_service).to receive(:split_file)
    end

    context 'when oc_source is companies' do
      let(:oc_source) { 'companies' }

      it 'calls service with correct params' do
        subject.call(month: month, local_path: local_path, oc_source: oc_source)

        expect(splitter_service).to have_received(:split_file).with(
          stream,
          s3_bucket: s3_bucket,
          s3_prefix: 'example/companies_s3_prefix/mth=2022_05',
          split_size: split_size,
          max_lines: max_lines
        )
      end
    end

    context 'when oc_source is add_ids' do
      let(:oc_source) { 'add_ids' }

      it 'calls service with correct params' do
        subject.call(month: month, local_path: local_path, oc_source: oc_source)

        expect(splitter_service).to have_received(:split_file).with(
          stream,
          s3_bucket: s3_bucket,
          s3_prefix: 'example/add_ids_s3_prefix/mth=2022_05',
          split_size: split_size,
          max_lines: max_lines
        )
      end
    end

    context 'when oc_source is alt_names' do
      let(:oc_source) { 'alt_names' }

      it 'calls service with correct params' do
        subject.call(month: month, local_path: local_path, oc_source: oc_source)

        expect(splitter_service).to have_received(:split_file).with(
          stream,
          s3_bucket: s3_bucket,
          s3_prefix: 'example/alt_names_s3_prefix/mth=2022_05',
          split_size: split_size,
          max_lines: max_lines
        )
      end
    end

    context 'when oc_source invalid' do
      let(:oc_source) { 'unknown_source' }

      it 'raises an error' do
        expect {
          subject.call(month: month, local_path: local_path, oc_source: oc_source)
        }.to raise_error RegisterIngesterOc::UnknownOcSourceError
      end
    end
  end

  describe '#bash_call' do
    subject { described_class }

    let(:app) { double 'app' }

    before do
      expect(described_class).to receive(:new).and_return app
      allow(app).to receive(:call)
    end

    it 'calls app with correct params' do
      subject.bash_call [oc_source, month, local_path]

      expect(app).to have_received(:call).with(oc_source: oc_source, month: month, local_path: local_path)
    end
  end
end
