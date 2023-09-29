# frozen_string_literal: true

require 'register_ingester_oc/alt_names/row_processor'

RSpec.describe RegisterIngesterOc::AltNames::RowProcessor do
  subject { described_class.new }

  let(:row) do
    {
      company_number: '123',
      jurisdiction_code: 'gb',
      name: 'name',
      type: 'type',
      start_date: '2020-07-26',
      end_date: '2021-09-12'
    }
  end

  describe '#process_row' do
    let(:expected_result) do
      RegisterSourcesOc::AltName.new(
        company_number: '123',
        jurisdiction_code: 'gb',
        name: 'name',
        type: 'type',
        start_date: '2020-07-26',
        end_date: '2021-09-12'
      )
    end

    it 'processes row correctly' do
      expect(subject.process_row(row)).to eq expected_result
    end
  end
end
