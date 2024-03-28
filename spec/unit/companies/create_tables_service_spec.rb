# frozen_string_literal: true

require 'register_ingester_oc/companies/create_tables_service'

RSpec.describe RegisterIngesterOc::Companies::CreateTablesService do
  subject do
    described_class.new(
      athena_adapter:,
      athena_database:,
      s3_bucket:,
      raw_table_name:,
      processed_table_name:,
      filtered_table_name:,
      bulk_data_s3_prefix:,
      processed_s3_location:,
      filtered_s3_location:
    )
  end

  let(:athena_adapter) { double 'athena_adapter' }
  let(:athena_database) { 'athena_database' }
  let(:s3_bucket) { 's3_bucket' }
  let(:raw_table_name) { 'raw_table_name' }
  let(:processed_table_name) { 'processed_table_name' }
  let(:filtered_table_name) { 'filtered_table_name' }
  let(:bulk_data_s3_prefix) { '/bulk' }
  let(:processed_s3_location) { '/processed' }
  let(:filtered_s3_location) { 'filtered' }

  describe '#call' do
    it 'calls athena with correct queries' do
      # Create raw table query
      create_raw_query = <<~SQL
        CREATE EXTERNAL TABLE IF NOT EXISTS raw_table_name (
          company_number STRING,
        jurisdiction_code STRING,
        name STRING,
        normalised_name STRING,
        company_type STRING,
        nonprofit STRING,
        current_status STRING,
        incorporation_date STRING,
        dissolution_date STRING,
        branch STRING,
        business_number STRING,
        current_alternative_legal_name STRING,
        current_alternative_legal_name_language STRING,
        home_jurisdiction_text STRING,
        native_company_number STRING,
        previous_names STRING,
        retrieved_at STRING,
        registry_url STRING,
        restricted_for_marketing STRING,
        inactive STRING,
        accounts_next_due STRING,
        accounts_reference_date STRING,
        accounts_last_made_up_date STRING,
        annual_return_next_due STRING,
        annual_return_last_made_up_date STRING,
        has_been_liquidated STRING,
        has_insolvency_history STRING,
        has_charges STRING,
        number_of_employees STRING,
        `registered_address.street_address` STRING,
        `registered_address.locality` STRING,
        `registered_address.region` STRING,
        `registered_address.postal_code` STRING,
        `registered_address.country` STRING,
        `registered_address.in_full` STRING,
        home_jurisdiction_code STRING,
        home_jurisdiction_company_number STRING,
        industry_code_uids STRING,
        latest_accounts_date STRING,
        latest_accounts_cash STRING,
        latest_accounts_assets STRING,
        latest_accounts_liabilities STRING

        )
        PARTITIONED BY (`mth` STRING, `part` STRING)
        ROW FORMAT SERDE 'org.apache.hadoop.hive.serde2.OpenCSVSerde'
        WITH SERDEPROPERTIES ("escapeChar"= "¬")
        LOCATION 's3://s3_bucket//bulk';
      SQL
      create_raw_execution_id = double 'create_raw_execution_id'
      create_raw_execution = double 'create_raw', query_execution_id: create_raw_execution_id
      expect(athena_adapter).to receive(:start_query_execution)
        .with({ query_string: create_raw_query,
                result_configuration: { output_location: 's3://s3_bucket/athena_results' } })
        .and_return create_raw_execution
      expect(athena_adapter).to receive(:wait_for_query).with create_raw_execution_id

      # Create processed table query
      create_processed_query = <<~SQL
        CREATE EXTERNAL TABLE IF NOT EXISTS `processed_table_name` (
          company_number STRING,
        jurisdiction_code STRING,
        name STRING,
        normalised_name STRING,
        company_type STRING,
        nonprofit STRING,
        current_status STRING,
        incorporation_date STRING,
        dissolution_date STRING,
        branch STRING,
        business_number STRING,
        current_alternative_legal_name STRING,
        current_alternative_legal_name_language STRING,
        home_jurisdiction_text STRING,
        native_company_number STRING,
        previous_names STRING,
        retrieved_at STRING,
        registry_url STRING,
        restricted_for_marketing STRING,
        inactive STRING,
        accounts_next_due STRING,
        accounts_reference_date STRING,
        accounts_last_made_up_date STRING,
        annual_return_next_due STRING,
        annual_return_last_made_up_date STRING,
        has_been_liquidated STRING,
        has_insolvency_history STRING,
        has_charges STRING,
        number_of_employees STRING,
        `registered_address.street_address` STRING,
        `registered_address.locality` STRING,
        `registered_address.region` STRING,
        `registered_address.postal_code` STRING,
        `registered_address.country` STRING,
        `registered_address.in_full` STRING,
        home_jurisdiction_code STRING,
        home_jurisdiction_company_number STRING,
        industry_code_uids STRING,
        latest_accounts_date STRING,
        latest_accounts_cash STRING,
        latest_accounts_assets STRING,
        latest_accounts_liabilities STRING

        )
        PARTITIONED BY (`mth` STRING, `part` STRING)
        ROW FORMAT SERDE
          'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
        STORED AS INPUTFORMAT
          'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat'
        OUTPUTFORMAT
          'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
        LOCATION '/processed'
        TBLPROPERTIES (
          'has_encrypted_data'='false',
          'parquet.compression'='GZIP');
      SQL
      create_processed_execution_id = double 'create_processed_execution_id'
      create_processed_execution = double 'create_processed', query_execution_id: create_processed_execution_id
      expect(athena_adapter).to receive(:start_query_execution)
        .with({ query_string: create_processed_query,
                result_configuration: { output_location: 's3://s3_bucket/athena_results' } })
        .and_return create_processed_execution
      expect(athena_adapter).to receive(:wait_for_query).with create_processed_execution_id

      # Create filtered query
      create_filtered_query = <<~SQL
        CREATE EXTERNAL TABLE IF NOT EXISTS `filtered_table_name` (
          company_number STRING,
          name STRING,
          company_type STRING,
          incorporation_date STRING,
          dissolution_date STRING,
          restricted_for_marketing BOOLEAN,
          `registered_address.country` STRING,
          `registered_address.in_full` STRING,
          industry_code_uids ARRAY<STRING>
        )
        PARTITIONED BY (`mth` STRING, `jurisdiction_code` STRING)
        ROW FORMAT SERDE
          'org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe'
        STORED AS INPUTFORMAT
          'org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat'
        OUTPUTFORMAT
          'org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat'
        LOCATION 'filtered'
        TBLPROPERTIES (
          'has_encrypted_data'='false',
          'parquet.compression'='GZIP');
      SQL
      create_filtered_execution_id = double 'create_filtered_execution_id'
      create_filtered_execution = double 'create_filtered', query_execution_id: create_filtered_execution_id
      expect(athena_adapter).to receive(:start_query_execution)
        .with({ query_string: create_filtered_query,
                result_configuration: { output_location: 's3://s3_bucket/athena_results' } })
        .and_return create_filtered_execution
      expect(athena_adapter).to receive(:wait_for_query).with create_filtered_execution_id

      subject.call
    end
  end
end
