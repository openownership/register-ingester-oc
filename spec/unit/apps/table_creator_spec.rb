require 'register_ingester_oc/apps/table_creator'

RSpec.describe RegisterIngesterOc::Apps::TableCreator do
  subject do
    described_class.new(create_tables_service: create_tables_service)
  end

  let(:create_tables_service) { double 'create_tables_service' }

  it 'calls service with correct params' do
    allow(create_tables_service).to receive(:call)

    subject.call

    expect(create_tables_service).to have_received(:call)
  end

  describe '#bash_call' do
    subject { described_class }

    let(:app) { double 'app' }

    before do
      expect(described_class).to receive(:new).and_return app
      allow(app).to receive(:call)
    end

    it 'calls app' do
      subject.bash_call

      expect(app).to have_received(:call)
    end
  end
end
