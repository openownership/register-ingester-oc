require 'register_ingester_oc/apps/es_ingestor'

RSpec.describe RegisterIngesterOc::Apps::EsIngestor do
  subject do
    described_class.new(
      file_reader: file_reader,
      company_repository: company_repository,
      s3_adapter: s3_adapter,
      s3_bucket: s3_bucket,
      diffs_s3_prefix: diffs_s3_prefix,
      full_s3_prefix: full_s3_prefix
    )
  end

  let(:file_reader) { double 'file_reader' }
  let(:company_repository) { double 'company_repository' }
  let(:s3_adapter) { double 's3_adapter' }
  let(:s3_bucket) { double 's3_bucket' }
  let(:diffs_s3_prefix) { 'prefix/diffs' }
  let(:full_s3_prefix) { 'prefix/full' }

  describe '#call' do
    let(:month) { '2022_05' }
    let(:import_type) { 'full' }

    context 'when import_type is valid' do
      let(:s3_path1) { double 's3_path1' }
      let(:s3_path2) { double 's3_path2' }
      let(:s3_paths) { [s3_path1, s3_path2] }
      let(:s3_prefix) { "prefix/full/mth=2022_05" }

      before do
        expect(s3_adapter).to receive(:list_objects).with(
          s3_bucket: s3_bucket,
          s3_prefix: s3_prefix
        ).and_return s3_paths

        s3_paths.each do |s3_path|
          expect(file_reader).to receive(:import_from_s3).with(
            s3_bucket: s3_bucket,
            s3_path: s3_path,
            file_format: 'json'
          )
        end
      end

      context 'with import_type diff' do
        let(:import_type) { 'diff' }
        let(:s3_prefix) { "prefix/diffs/mth=2022_05" }

        it 'imports from diffs s3_prefix' do
          subject.call(month: month, import_type: import_type)
        end
      end

      context 'with import_type full' do
        let(:import_type) { 'full' }
        let(:s3_prefix) { "prefix/full/mth=2022_05" }

        it 'imports from full s3_prefix' do
          subject.call(month: month, import_type: import_type)
        end
      end
    end

    context 'when import_type is unknown' do
      let(:import_type) { 'unknown' }

      it 'raises UnknownImportTypeError' do
        expect do
          subject.call(month: month, import_type: import_type)
        end.to raise_error described_class::UnknownImportTypeError
      end
    end
  end
end
