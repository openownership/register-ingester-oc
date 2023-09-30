# frozen_string_literal: true

require 'register_ingester_oc/apps/es_ingestor'

RSpec.describe RegisterIngesterOc::Apps::EsIngestor do
  subject do
    described_class.new(
      companies_ingestor_service:,
      alt_names_ingestor_service:,
      add_ids_ingestor_service:
    )
  end

  let(:companies_ingestor_service) { double 'companies_ingestor_service' }
  let(:alt_names_ingestor_service) { double 'alt_names_ingestor_service' }
  let(:add_ids_ingestor_service) { double 'add_ids_ingestor_service' }

  let(:oc_source) { 'companies' }
  let(:month) { '2022_05' }

  describe '#call' do
    before do
      allow(companies_ingestor_service).to receive(:call)
      allow(alt_names_ingestor_service).to receive(:call)
      allow(add_ids_ingestor_service).to receive(:call)
    end

    context 'when oc_source is companies' do
      let(:oc_source) { 'companies' }

      it 'calls service with correct params' do
        subject.call(oc_source, month)

        expect(companies_ingestor_service).to have_received(:call).with(month)
      end
    end

    context 'when oc_source is add_ids' do
      let(:oc_source) { 'add_ids' }

      it 'calls service with correct params' do
        subject.call(oc_source, month)

        expect(add_ids_ingestor_service).to have_received(:call).with(month)
      end
    end

    context 'when oc_source is alt_names' do
      let(:oc_source) { 'alt_names' }

      it 'calls service with correct params' do
        subject.call(oc_source, month)

        expect(alt_names_ingestor_service).to have_received(:call).with(month)
      end
    end

    context 'when oc_source invalid' do
      let(:oc_source) { 'unknown_source' }

      it 'raises an error' do
        expect do
          subject.call(oc_source, month)
        end.to raise_error RegisterIngesterOc::UnknownOcSourceError
      end
    end
  end

  describe '#bash_call' do
    subject { described_class }

    let(:app) { double 'app' }

    # rubocop:disable RSpec/ExpectInHook
    before do
      expect(described_class).to receive(:new).and_return app
      allow(app).to receive(:call)
    end
    # rubocop:enable RSpec/ExpectInHook

    it 'calls app with correct params' do
      oc_source = 'companies'
      month = '202205'

      subject.bash_call [oc_source, month]

      expect(app).to have_received(:call).with(oc_source, month)
    end
  end
end
