# frozen_string_literal: true

require 'register_ingester_oc/add_ids/row_processor'

RSpec.describe RegisterIngesterOc::AddIds::RowProcessor do
  subject { described_class.new }

  let(:row) do
    {
      company_number: '123',
      jurisdiction_code: '',
      uid: 'uid',
      identifier_system_code: 'identifier_system_code'
    }
  end

  describe '#process_row' do
    let(:expected_result) do
      RegisterSourcesOc::AddId.new(
        company_number: '123',
        jurisdiction_code: nil,
        uid: 'uid',
        identifier_system_code: 'identifier_system_code'
      )
    end

    it 'processes row correctly' do
      expect(subject.process_row(row)).to eq expected_result
    end
  end
end
