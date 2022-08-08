require 'register_ingester_oc/companies/row_processor'

RSpec.describe RegisterIngesterOc::Companies::RowProcessor do
  subject { described_class.new }

  let(:row) do
    {
      company_number: '123',
      jurisdiction_code: 'gb',
      name: 'name',
      company_type: 'company_type',
      incorporation_date: '2020-09-01',
      dissolution_date: '2022-04-01',
      restricted_for_marketing: nil,
      :"registered_address.in_full" => 'registered address',
      :"registered_address.country" => 'country',
    }
  end

  describe '#process_row' do
    let(:expected_result) do
      RegisterSourcesOc::Company.new(
        company_number: '123',
        jurisdiction_code: 'gb',
        name: 'name',
        company_type: 'company_type',
        incorporation_date: '2020-09-01',
        dissolution_date: '2022-04-01',
        restricted_for_marketing: nil,
        registered_address_in_full: 'registered address',
        registered_address_country: 'country',
      )
    end

    it 'processes row correctly' do
      expect(subject.process_row(row)).to eq expected_result
    end
  end
end
