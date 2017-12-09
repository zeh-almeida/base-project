require 'rails_helper'

shared_examples 'is localizable' do
  let(:model) { described_class }
  let(:model_factory) { model.to_s.underscore.to_sym }

  context 'Columns' do
    it { should have_db_column(:latitude).of_type(:float).with_options(null: true) }
    it { should have_db_column(:longitude).of_type(:float).with_options(null: true) }
  end

  describe '#coordinates' do
    it 'should return the coordinate pair' do
      latitude = ((rand * 180) - 90).round(11)
      longitude = ((rand * 360) - 180).round(11)

      localizable = FactoryGirl.build(model_factory, latitude: latitude, longitude: longitude)
      expect(localizable.coordinates).to eq([longitude, latitude])
    end
  end

  describe '#near' do
    context 'should have a latitude' do
      it { should have_db_column(:latitude).of_type(:float).with_options(null: true) }
    end

    context 'should have a longitude' do
      it { should have_db_column(:longitude).of_type(:float).with_options(null: true) }
    end

    context 'should locate near locations' do
      it do
        models = described_class.near(subject.latitude, subject.longitude, 5)
        expect(models.size).to eq(0)
      end
    end
  end
end
