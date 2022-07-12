require 'register_ingester_oc/alt_names/reader'

RSpec.describe RegisterIngesterOc::AltNames::Reader do
  subject do
    described_class.new(
      csv_reader: csv_reader,
      json_reader: json_reader,
      zip_reader: zip_reader
    )
  end

  let(:csv_reader) { double 'csv_reader' }
  let(:json_reader) { double 'json_reader' }
  let(:zip_reader) { double 'zip_reader' }

  let(:rows) do
    [
      {
        company_number: '123',
        jurisdiction_code: 'gb',
        name: 'name',
        type: 'type',
        start_date: '2020-07-26',
        end_date: '2021-09-12'
      }
    ]
  end

  describe '#foreach' do
    let(:zipped) { false }
    let(:stream) { double 'stream' }
    let(:input_stream) { stream }

    let(:expected_results) do
      rows.map do |row|
        row = row.dup
        RegisterSourcesOc::AltName.new(**row)
      end
    end

    let(:results) do
      res = []
      subject.foreach(input_stream, file_format: file_format, zipped: zipped) do |row|
        res << row
      end
      res
    end

    context 'when format is csv' do
      let(:file_format) { 'csv' }

      before do
        expect(csv_reader).to receive(:foreach).with(stream).and_yield(
          *rows
        )
      end

      context 'with zipped stream' do
        let(:zipped) { true }

        before do
          expect(zip_reader).to receive(:open_stream).with(input_stream).and_yield(
            stream
          )
        end

        it 'reads stream correctly' do
          expect(results).to eq expected_results
        end
      end

      context 'with unzipped stream' do
        let(:zipped) { false }

        before do
          expect(zip_reader).not_to receive(:open_stream)
        end

        it 'reads stream correctly' do
          expect(results).to eq expected_results
        end
      end
    end

    context 'when format is json' do
      let(:file_format) { 'json' }

      before do
        expect(json_reader).to receive(:foreach).with(stream).and_yield(
          *rows
        )
      end

      context 'with zipped stream' do
        let(:zipped) { true }

        before do
          expect(zip_reader).to receive(:open_stream).with(input_stream).and_yield(
            stream
          )
        end

        it 'reads stream correctly' do
          expect(results).to eq expected_results
        end
      end

      context 'with unzipped stream' do
        let(:zipped) { false }

        before do
          expect(zip_reader).not_to receive(:open_stream)
        end

        it 'reads stream correctly' do
          expect(results).to eq expected_results
        end
      end
    end
  end
end
