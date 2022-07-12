require 'register_ingester_oc/add_ids/conversion_service'

RSpec.describe RegisterIngesterOc::AddIds::ConversionService do
  subject do
    described_class.new(
      athena_adapter: athena_adapter,
      athena_database: athena_database,
      s3_bucket: s3_bucket,
      raw_table_name: raw_table_name,
      processed_table_name: processed_table_name,
      filtered_table_name: filtered_table_name
    )
  end

  let(:athena_adapter) { double 'athena_adapter' }
  let(:athena_database) { 'athena_database' }
  let(:s3_bucket) { 's3_bucket' }
  let(:raw_table_name) { 'raw_table_name' }
  let(:processed_table_name) { 'processed_table_name' }
  let(:filtered_table_name) { 'filtered_table_name' }

  describe '#call' do
    let(:month) { '2022_05' }
    let(:jurisdiction_codes) { ['gb', 'dk'] }

    it 'calls athena with correct queries' do
      # Repair table query
      expect(athena_adapter).to receive(:execute_and_wait).with(
        "MSCK REPAIR TABLE raw_table_name\n",
        "s3://s3_bucket/athena_results"
      )

      # Convert table query
      expect(athena_adapter).to receive(:execute_and_wait).with(
        "INSERT INTO processed_table_name\nSELECT * FROM raw_table_name\nWHERE mth = '2022_05';\n",
        "s3://s3_bucket/athena_results"
      )

      # Inserts into filtered table
      expect(athena_adapter).to receive(:execute_and_wait).with(
        "INSERT INTO filtered_table_name\nSELECT\n  company_number,\n  uid,\n  identifier_system_code,\n  mth,\n  jurisdiction_code\nFROM processed_table_name\nWHERE mth = '2022_05' AND jurisdiction_code IN ('gb', 'dk');\n",
        "s3://s3_bucket/athena_results"
      )

      subject.call month, jurisdiction_codes: jurisdiction_codes
    end
  end
end
