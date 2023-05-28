require 'register_ingester_oc/apps/table_creator'

RSpec.describe RegisterIngesterOc::Apps::TableCreator do
  subject do
    described_class.new(
      companies_table_service:,
      alt_names_table_service:,
      add_ids_table_service:,
    )
  end

  let(:companies_table_service) { double 'companies_table_service' }
  let(:alt_names_table_service) { double 'alt_names_table_service' }
  let(:add_ids_table_service) { double 'add_ids_table_service' }

  let(:oc_source) { 'companies' }

  describe '#call' do
    before do
      allow(companies_table_service).to receive(:call)
      allow(alt_names_table_service).to receive(:call)
      allow(add_ids_table_service).to receive(:call)
    end

    context 'when oc_source is companies' do
      let(:oc_source) { 'companies' }

      it 'calls service with correct params' do
        subject.call(oc_source)

        expect(companies_table_service).to have_received(:call)
      end
    end

    context 'when oc_source is add_ids' do
      let(:oc_source) { 'add_ids' }

      it 'calls service with correct params' do
        subject.call(oc_source)

        expect(add_ids_table_service).to have_received(:call)
      end
    end

    context 'when oc_source is alt_names' do
      let(:oc_source) { 'alt_names' }

      it 'calls service with correct params' do
        subject.call(oc_source)

        expect(alt_names_table_service).to have_received(:call)
      end
    end

    context 'when oc_source invalid' do
      let(:oc_source) { 'unknown_source' }

      it 'raises an error' do
        expect do
          subject.call(oc_source)
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

      subject.bash_call [oc_source]

      expect(app).to have_received(:call).with(oc_source)
    end
  end
end
