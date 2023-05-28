require 'register_ingester_oc/apps/oc_downloader'

RSpec.describe RegisterIngesterOc::Apps::OcDownloader do
  subject do
    described_class.new(download_service:)
  end

  let(:download_service) { double 'download_service' }

  let(:oc_source) { 'companies' }
  let(:month) { '2022_05' }
  let(:dst_path) { 'local_path' }

  describe '#call' do
    before do
      allow(download_service).to receive(:download)
    end

    context 'when oc_source is companies' do
      let(:oc_source) { 'companies' }

      it 'calls service with correct params' do
        subject.call(oc_source, month, dst_path)

        expect(download_service).to have_received(:download).with(
          month,
          dst_path,
          filename: 'companies.csv.gz',
        )
      end
    end

    context 'when oc_source is add_ids' do
      let(:oc_source) { 'add_ids' }

      it 'calls service with correct params' do
        subject.call(oc_source, month, dst_path)

        expect(download_service).to have_received(:download).with(
          month,
          dst_path,
          filename: 'additional_identifiers.csv.gz',
        )
      end
    end

    context 'when oc_source is alt_names' do
      let(:oc_source) { 'alt_names' }

      it 'calls service with correct params' do
        subject.call(oc_source, month, dst_path)

        expect(download_service).to have_received(:download).with(
          month,
          dst_path,
          filename: 'alternative_names.csv.gz',
        )
      end
    end

    context 'when oc_source invalid' do
      let(:oc_source) { 'unknown_source' }

      it 'raises an error' do
        expect do
          subject.call(oc_source, month, dst_path)
        end.to raise_error RegisterIngesterOc::UnknownOcSourceError
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
      oc_source = 'companies'
      month = '202205'
      dst_path = double 'dst_path'

      subject.bash_call [oc_source, month, dst_path]

      expect(app).to have_received(:call).with(oc_source, month, dst_path)
    end
  end
end
