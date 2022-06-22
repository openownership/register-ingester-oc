require 'register_ingester_oc/apps/oc_downloader'

RSpec.describe RegisterIngesterOc::Apps::OcDownloader do
  subject do
    described_class.new(download_service: download_service)
  end

  let(:download_service) { double 'download_service' }

  it 'calls service with correct params' do
    allow(download_service).to receive(:download)

    month = '202205'
    local_path = double 'local_path'

    subject.call month, local_path

    expect(download_service).to have_received(:download).with(month, local_path)
  end

  describe '#bash_call' do
    subject { described_class }

    let(:app) { double 'app' }

    before do
      expect(described_class).to receive(:new).and_return app
      allow(app).to receive(:call)
    end

    it 'calls app with correct params' do
      month = '202205'
      local_path = double 'local_path'

      args = [month, local_path]

      subject.bash_call args

      expect(app).to have_received(:call).with(month, local_path)
    end
  end
end
