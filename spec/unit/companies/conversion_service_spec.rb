require 'register_ingester_oc/companies/conversion_service'

RSpec.describe RegisterIngesterOc::Companies::ConversionService do
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
      repair_execution_id = double 'repair_execution_id'
      repair_execution = double 'repair', query_execution_id: repair_execution_id
      expect(athena_adapter).to receive(:start_query_execution).with(
        query_string: "MSCK REPAIR TABLE raw_table_name\n",
        result_configuration: { output_location: "s3://s3_bucket/athena_results" }
      ).and_return repair_execution
      expect(athena_adapter).to receive(:wait_for_query).with repair_execution_id

      # Convert table query
      convert_execution_id = double 'convert_execution_id'
      convert_execution = double 'convert', query_execution_id: convert_execution_id
      expect(athena_adapter).to receive(:start_query_execution).with(
        query_string: "INSERT INTO processed_table_name\nSELECT * FROM raw_table_name\nWHERE mth = '2022_05';\n",
        result_configuration: { output_location: "s3://s3_bucket/athena_results" }
      ).and_return convert_execution
      expect(athena_adapter).to receive(:wait_for_query).with convert_execution_id

      # Inserts into filtered table
      filter_execution_id = double 'filter_execution_id'
      filter_execution = double 'filter', query_execution_id: filter_execution_id
      expect(athena_adapter).to receive(:start_query_execution).with(
        query_string: "INSERT INTO filtered_table_name\nSELECT\n  company_number,\n  name,\n  company_type,\n  incorporation_date,\n  dissolution_date,\n  CASE lower(restricted_for_marketing)\n    WHEN 'true' THEN TRUE\n    WHEN 't' THEN TRUE\n    WHEN 'false' THEN FALSE\n    WHEN 'f' THEN FALSE\n    ELSE NULL\n  END AS restricted_for_marketing,\n  \"registered_address.country\",\n  \"registered_address.in_full\",\n  mth,\n  jurisdiction_code\nFROM processed_table_name\nWHERE mth = '2022_05' AND jurisdiction_code IN ('gb', 'dk');\n",
        result_configuration: { output_location: "s3://s3_bucket/athena_results" }
      ).and_return filter_execution
      expect(athena_adapter).to receive(:wait_for_query).with filter_execution_id

      subject.call month, jurisdiction_codes: jurisdiction_codes
    end
  end
end
