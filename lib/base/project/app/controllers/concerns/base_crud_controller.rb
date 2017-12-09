
module BaseCrudController
  extend ActiveSupport::Concern

  @serializer_class ||= nil

  included do
    before_action :check_default_permission
    before_action :set_model, only: %i[show update destroy]

    def index
      @models = apply_scopes(model_source)

      respond_with(@models) do |format|
        format.html { flash.now[:info] = t('simple_form.results', count: @models.size) }
        format.json { render json: @models, serializer_each: @serializer_class }
      end
    end

    def show
      respond_with(@model) do |format|
        format.html {}
        format.json { render json: @model, serializer: @serializer_class }
      end
    end

    def new
      @model = model_source.new

      respond_with(@model) do |format|
        format.html {}
        format.json { render json: @model, serializer: @serializer_class }
      end
    end

    def create
      @model = model_source.new(model_params)
      is_save = @model.save

      respond_with(@model) do |format|
        format.html do
          if is_save
            redirect_to created_path, notice: t('simple_form.added', klass: model_name)
          else
            flash.now[:error] = t('simple_form.error_notification.default_message')
            render action: 'new'
          end
        end

        format.json do
          if is_save
            head :created
          else
            render json: @model.errors, status: :unprocessable_entity
          end
        end
      end
    end

    def update
      is_save = @model.update(update_model_params)

      respond_with(@model) do |format|
        format.html do
          if is_save
            flash.now[:success] = t('simple_form.updated', klass: model_name)
          else
            flash.now[:error] = t('simple_form.error_notification.default_message')
            render action: 'show'
          end
        end

        format.json do
          if is_save
            head :no_content
          else
            render json: @model.errors, status: :unprocessable_entity
          end
        end
      end
    end

    def destroy
      @model.destroy

      respond_to do |format|
        format.html { redirect_to destroyed_path, notice: t('simple_form.removed', klass: model_name) }
        format.json { head :no_content }
      end
    end

    private

    def set_model
      @model = model_source.find(params[:id])
    end
  end

  module ClassMethods
    def serializer(klass)
      @serializer_class = klass
    end
  end
end
