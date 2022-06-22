require 'register_ingester_oc/apps/oc_converter'

RSpec.describe RegisterIngesterOc::Apps::OcConverter do
  subject do
    described_class.new(conversion_service: conversion_service)
  end

  let(:conversion_service) { double 'conversion_service' }

  it 'calls service with correct params' do
    month = '202205'
    allow(conversion_service).to receive(:call)

    subject.call month

    expect(conversion_service).to have_received(:call).with(month)
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

      args = [month]

      subject.bash_call args

      expect(app).to have_received(:call).with(month)
    end
  end
end
