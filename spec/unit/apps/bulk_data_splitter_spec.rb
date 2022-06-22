require 'register_ingester_oc/apps/bulk_data_splitter'

RSpec.describe RegisterIngesterOc::Apps::BulkDataSplitter do
  subject do
    described_class.new(
      s3_bucket: s3_bucket,
      s3_prefix: s3_prefix,
      splitter_service: splitter_service,
      split_size: split_size,
      max_lines: max_lines
    )
  end

  let(:s3_bucket) { double 's3_bucket' }
  let(:s3_prefix) { 'example/prefix' }
  let(:splitter_service) { double 'splitter_service' }
  let(:split_size) { double 'split_size' }
  let(:max_lines) { double 'max_lines' }

  it 'calls service with correct params' do
    month = '202205'
    local_path = double 'local_path'

    stream = double 'stream'
    expect(File).to receive(:open).with(local_path, 'rb').and_yield stream
    allow(splitter_service).to receive(:split_file)

    subject.call(month: month, local_path: local_path)

    expect(splitter_service).to have_received(:split_file).with(
      stream,
      s3_bucket: s3_bucket,
      s3_prefix: 'example/prefix/mth2=202205',
      split_size: split_size,
      max_lines: max_lines
    )
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
      local_path = double 'local_path'

      args = [month, local_path]

      subject.bash_call args

      expect(app).to have_received(:call).with(month: month, local_path: local_path)
    end
  end
end
