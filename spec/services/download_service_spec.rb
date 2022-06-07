require 'register_ingester_oc/services/download_service'

RSpec.describe RegisterIngesterOc::Services::DownloadService do
  subject { described_class.new(sftp_adapter: sftp_adapter, filename: filename, settings: settings) }

  let(:sftp_adapter) { double 'sftp_adapter'}
  let(:filename) { 'md5sum.txt' }
  let(:settings) { double('settings', OC_HOST: 'oc_host', OC_USERNAME: 'oc_user', OC_PASSWORD: 'oc_password') }

  describe '#download' do
    it 'calls sftp adapter correctly' do
      allow(sftp_adapter).to receive(:download_file)

      month = '2022_05'
      dst_path = '/tmp/something'

      subject.download(month, dst_path)

      expect(sftp_adapter).to have_received(:download_file).with(
        host: settings.OC_HOST,
        username: settings.OC_USERNAME,
        password: settings.OC_PASSWORD,
        rem_path: '/2022_05/md5sum.txt',
        dst_path: dst_path
      )
    end
  end
end
