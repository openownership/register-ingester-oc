require 'register_ingester_oc/apps/oc_exporter'

RSpec.describe RegisterIngesterOc::Apps::OcExporter do
  subject do
    described_class.new(exporter_service: exporter_service)
  end

  let(:exporter_service) { double 'exporter_service' }

  it 'calls service with correct params' do
    month = '202205'
    allow(exporter_service).to receive(:call)

    subject.call month

    expect(exporter_service).to have_received(:call).with(month)
  end

  describe '#bash_call' do
    subject { described_class }

    let(:app) { double 'app' }

    before do
      expect(described_class).to receive(:new).and_return app
      allow(app).to receive(:call)
    end

    it 'calls app with correct params' do
      month = double 'month'

      args = [month]

      subject.bash_call args

      expect(app).to have_received(:call).with(month)
    end
  end
end
