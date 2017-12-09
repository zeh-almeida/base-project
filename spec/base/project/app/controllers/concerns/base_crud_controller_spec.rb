require 'rails_helper'

shared_examples 'as a base crud controller' do
  let(:user)          { FactoryGirl.create(:user) }
  let(:user_type)     { user.user_type }
  let(:klass)         { described_class.controller_name.classify }
  let(:model_factory) { klass.underscore.to_sym }
  let(:serializer)    { Object.const_get("#{klass}Serializer") }
  let(:model)         { FactoryGirl.create(model_factory) }
  let(:serialization) { serializer.new(model, {}) }

  let(:create_params) { {} }
  let(:update_params) { FactoryGirl.build(model_factory).attributes.except('id', 'created_at', 'updated_at') }

  before do
    sign_in(user)
  end

  context 'Permission' do
    context ':json' do
      it 'fails for a user without permission' do
        params = base_params.merge(format: :json)
        get :index, params

        expect(response.code).to eq('302')
        expect(response).to redirect_to(error_401_path)
      end
    end
  end

  context 'Actions' do
    before do
      prepare_permissions(user, klass.underscore)
    end

    context '#index' do
      it 'returns all models' do
        test = model.id > 0
        params = base_params.merge(format: :json)

        get :index, params
        result = JSON.parse(response.body)

        expect(result.length).to eq(1)
        expect(result.first).to eq(JSON.parse(serialization.to_json))
      end
    end

    context '#show' do
      it 'returns the current model' do
        params = base_params.merge(id: model.id, format: :json)

        get :show, params
        result = JSON.parse(response.body)

        expect(result).to eq(JSON.parse(serialization.to_json))
      end
    end

    context '#new' do
      it 'returns a new base model' do
        params = base_params.merge(format: :json)

        get :new, params
        result = JSON.parse(response.body)

        new_model = subject.model_source.new
        new_serialized = serializer.new(new_model, {})

        expect(result).to eq(JSON.parse(new_serialized.to_json))
      end
    end

    context '#create' do
      it 'creates a model' do
        base_attributes = FactoryGirl.build(model_factory, base_params.merge(create_params)).attributes.except('id', 'created_at', 'updated_at', 'encrypted_password')
        attributes = {"#{model_factory}": base_attributes.merge(base_params)}
        params = attributes.merge(base_params).merge(format: :json)

        post :create, params

        expect(response.code).to eq('201')
        expect(subject.model_source.reorder(:id).last.attributes).to include(base_attributes)
      end

      it 'responds with errors when the model is invalid' do
        base_attributes = model.attributes
        base_attributes.each do |key, _|
          base_attributes[key] = ''
        end

        attributes = {"#{model_factory}": base_attributes.merge(base_params)}
        params = attributes.merge(base_params).merge(id: model.id, format: :json)

        post :create, params
        expect(response.code).to eq('422')
      end

      it 'redirects to the created model when HTML' do
        base_attributes = FactoryGirl.build(model_factory, base_params).attributes.except('id', 'created_at', 'updated_at').merge(create_params)
        attributes = {"#{model_factory}": base_attributes.merge(base_params)}
        params = attributes.merge(base_params)

        post :create, params

        redirect_params = base_params.merge(id: subject.model_source.reorder(:id).last.id, action: :show)
        expect(subject).to redirect_to redirect_params
      end
    end

    context '#update' do
      it 'updates a model' do
        original_update = model.updated_at

        base_attributes = model.attributes.except('created_at', 'updated_at').merge(update_params)
        attributes = {"#{model_factory}": base_attributes.merge(base_params)}
        params = attributes.merge(base_params).merge(id: model.id, format: :json)

        Timecop.freeze(Time.now + 1.hours) do
          put :update, params

          expect(response.code).to eq('204')
          expect(original_update).to be < model.reload.updated_at
        end
      end

      it 'responds with errors when the model is invalid' do
        base_attributes = model.attributes
        base_attributes.each do |key, _|
          base_attributes[key] = ''
        end

        attributes = {"#{model_factory}": base_attributes.merge(base_params)}
        params = attributes.merge(base_params).merge(id: model.id, format: :json)

          put :update, params
        expect(response.code).to eq('422')
      end
    end

    context '#destroy' do
      it 'removes the current model from the system' do
        params = base_params.merge(id: model.id, format: :json)

        delete :destroy, params

        expect(response.code).to eq('204')
        expect { model.reload }.to raise_exception(ActiveRecord::RecordNotFound)
      end

      it 'redirects to index after removing model when HTML' do
        new_model = FactoryGirl.create(model_factory, base_params)
        params = base_params.merge(id: new_model.id, format: :html)

              delete :destroy, params

        redirect_params = base_params.merge(action: :index)
        expect(subject).to redirect_to redirect_params
      end
    end
  end
end
