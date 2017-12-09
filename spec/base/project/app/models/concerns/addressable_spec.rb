require 'rails_helper'

shared_examples 'is addressible' do
  let(:model) { described_class }
  let(:model_factory) { model.to_s.underscore.to_sym }
  let(:factory) { FactoryGirl.build(model_factory) }

  context 'Columns' do
    it { should have_db_column(:id).of_type(:integer).with_options(null: false) }
    it { should have_db_column(:default).of_type(:boolean).with_options(null: false, default: false) }
    it { should have_db_column(:name).of_type(:text).with_options(null: false, length: 100) }
    it { should have_db_column(:country).of_type(:text).with_options(null: false, default: 'br', length: 2) }
    it { should have_db_column(:state).of_type(:text).with_options(null: false, length: 100) }
    it { should have_db_column(:city).of_type(:text).with_options(null: false, length: 100) }
    it { should have_db_column(:street).of_type(:text).with_options(null: false, length: 100) }
    it { should have_db_column(:number).of_type(:integer).with_options(null: false) }
    it { should have_db_column(:zipcode).of_type(:text).with_options(null: false, length: 8) }
    it { should have_db_column(:district).of_type(:text).with_options(null: false, length: 100) }
    it { should have_db_column(:latitude).of_type(:float).with_options(null: true) }
    it { should have_db_column(:longitude).of_type(:float).with_options(null: true) }
    it { should have_db_column(:apartment).of_type(:integer).with_options(null: true) }
    it { should have_db_column(:block).of_type(:text).with_options(null: true, length: 100) }
  end

  context 'Indexes' do
    it { should have_db_index(:zipcode) }
    it { should have_db_index(%i[apartment block]) }
  end

  context '#formatted_simple' do
    it 'should have street, number, district and city' do
      formatted = factory.formatted_simple
      expect(formatted).to include(factory.street)
      expect(formatted).to include(factory.number.to_s)
      expect(formatted).to include(factory.district)
      expect(formatted).to include(factory.city)
    end

    it 'should have apartment if supplied' do
      apartment = FFaker.numerify('###').to_i.to_s

      expect(factory.formatted_simple).not_to include(apartment)

      factory.apartment = apartment
      expect(factory.formatted_simple).to include(apartment)
    end

    it 'should have block if supplied' do
      block = FFaker.numerify('###').to_i.to_s

      expect(factory.formatted_simple).not_to include(block)

      factory.block = block
      expect(factory.formatted_simple).to include(block)
    end
  end

  context '#formatted_zipcode' do
    it 'should mask as #####-###' do
      zipcode = FFaker.numerify('#####-###')
      with_zip = FactoryGirl.build(model_factory, zipcode: zipcode)

      expect(with_zip.formatted_zipcode).to eq(zipcode)
    end
  end

  context '#formatted_country' do
    it 'should equal the countrys ISO3166 name' do
      country = ISO3166::Country[factory.country]

      expect(factory.formatted_country).to eq(country.translations[factory.country])
    end
  end

  context '#formatted_complete' do
    it 'should contain all formatted attributes' do
      formatted = factory.formatted_complete

      expect(formatted).to include(factory.formatted_simple)
      expect(formatted).to include(factory.formatted_zipcode)
      expect(formatted).to include(factory.formatted_country)
    end
  end

  context 'Validations' do
    it 'should have valid factory' do
      expect(factory).to be_valid, -> { factory.errors.full_messages.join("\n") }
    end

    it 'should require a name' do
      model = FactoryGirl.build(model_factory, name: '')
      expect(model).not_to be_valid
    end

    it 'should require a name less than 100 letters' do
      model1 = FactoryGirl.build(model_factory, name: get_string(105))
      expect(model1).not_to be_valid

      model2 = FactoryGirl.build(model_factory, name: get_string(100))
      expect(model2).to be_valid
    end

    it 'should require a country' do
      expect(FactoryGirl.build(model_factory, country: '')).not_to be_valid
    end

    it 'should require a country less than 2 letters' do
      expect(FactoryGirl.build(model_factory, country: get_string(105))).not_to be_valid
      expect(FactoryGirl.build(model_factory, country: get_string(100))).not_to be_valid
      expect(FactoryGirl.build(model_factory, country: FFaker::Address.country_code)).to be_valid
    end

    it 'should require a state' do
      expect(FactoryGirl.build(model_factory, state: '')).not_to be_valid
    end

    it 'should require a state less than 100 letters' do
      expect(FactoryGirl.build(model_factory, state: get_string(105))).not_to be_valid
      expect(FactoryGirl.build(model_factory, state: get_string(100))).to be_valid
    end

    it 'should require a city' do
      expect(FactoryGirl.build(model_factory, city: '')).not_to be_valid
    end

    it 'should require a city less than 100 letters' do
      expect(FactoryGirl.build(model_factory, city: get_string(105))).not_to be_valid
      expect(FactoryGirl.build(model_factory, city: get_string(100))).to be_valid
    end

    it 'should require a street' do
      expect(FactoryGirl.build(model_factory, street: '')).not_to be_valid
    end

    it 'should require a street less than 100 letters' do
      expect(FactoryGirl.build(model_factory, street: get_string(105))).not_to be_valid
      expect(FactoryGirl.build(model_factory, street: get_string(100))).to be_valid
    end

    it 'should require a number' do
      expect(FactoryGirl.build(model_factory, number: 0)).to be_valid
      expect(FactoryGirl.build(model_factory, number: nil)).not_to be_valid
    end

    it 'should require a district' do
      expect(FactoryGirl.build(model_factory, district: '')).not_to be_valid
    end

    it 'should require a district less than 100 letters' do
      expect(FactoryGirl.build(model_factory, district: get_string(105))).not_to be_valid
      expect(FactoryGirl.build(model_factory, district: get_string(100))).to be_valid
    end

    it 'should require a zipcode' do
      expect(FactoryGirl.build(model_factory, zipcode: '')).not_to be_valid
    end

    it 'should require a zipcode of 8 digits' do
      expect(FactoryGirl.build(model_factory, zipcode: FFaker.hexify('#######'))).to be_invalid
      expect(FactoryGirl.build(model_factory, zipcode: FFaker.numerify('#########'))).to be_invalid
      expect(FactoryGirl.build(model_factory, zipcode: FFaker.numerify('########'))).to be_valid
    end

    it 'should validate block if available' do
      expect(FactoryGirl.build(model_factory, block: nil)).to be_valid
      expect(FactoryGirl.build(model_factory, block: '')).to be_valid
      expect(FactoryGirl.build(model_factory, block: get_string(2))).to be_valid
      expect(FactoryGirl.build(model_factory, block: get_string(105))).not_to be_valid
      expect(FactoryGirl.build(model_factory, block: get_string(100))).to be_valid
    end

    it 'should round latitude if has more than 11 digits' do
      latitude = ((rand * 180) - 90).round(12)
      address = FactoryGirl.build(model_factory, latitude: latitude)
      address.valid?

      expect(address.latitude).to eq(latitude.round(11))
    end

    it 'should round longitude if has more than 11 digits' do
      longitude = ((rand * 360) - 180).round(12)
      address = FactoryGirl.build(model_factory, longitude: longitude)
      address.valid?

      expect(address.longitude).to eq(longitude.round(11))
    end
  end

  context 'Scopes' do
    before do
      FactoryGirl.create_list(model_factory, rand(7...14))
    end

    context '#by_name' do
      it 'should select only the address with the desired name' do
        element = model.all.sample
        query = model.by_name(element.name)

        expect(query.count).to eq(1)
        expect(query).to include(element)
      end
    end

    context '#by_country' do
      it 'should select only addresses from the desired ccountry' do
        element = FactoryGirl.create(model_factory, country: 'us')
        query = model.by_country(element.country)

        expect(query).to include(element)
      end
    end

    context '#by_city' do
      it 'should select only addresses from the desired city' do
        element = model.all.sample
        query = model.by_city(element.city)

        expect(query).to include(element)
      end
    end

    context '#by_street' do
      it 'should select only addresses from the desired street' do
        element = model.all.sample
        query = model.by_street(element.street)

        expect(query).to include(element)
      end
    end

    context '#by_number' do
      it 'should select only addresses from the desired number' do
        element = model.all.sample
        query = model.by_number(element.number)

        expect(query).to include(element)
      end
    end

    context '#by_district' do
      it 'should select only addresses from the desired district' do
        element = model.all.sample
        query = model.by_district(element.district)

        expect(query).to include(element)
      end
    end

    context '#by_zipcode' do
      it 'should select only addresses from the desired zipcode' do
        element = model.all.sample
        query = model.by_zipcode(element.zipcode)

        expect(query).to include(element)
      end
    end
  end

  context 'Convertions' do
    let(:localized_model) { FactoryGirl.create(model_factory, :localized) }

    context '#coordinates' do
      it 'should generate the Latitude/Longitude pair' do
        pair = localized_model.coordinate_pair
        expect(pair).to eq([localized_model.latitude, localized_model.longitude])
      end
    end

    context '#coordinates_dms' do
      it 'should convert the Latitude/Longitude pair to a DMS pair' do
        dms = localized_model.coordinates_dms
        expect(dms.length).to eq(2)
      end
    end
  end
end
