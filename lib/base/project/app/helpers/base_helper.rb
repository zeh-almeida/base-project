
module Base::Project::App::Helpers::BaseHelper
  def bootstrap_class_for(flash_type)
    case flash_type.to_sym
    when :success
      'alert-success' # Green
    when :error
      'alert-danger' # Red
    when :alert
      'alert-warning' # Yellow
    when :notice
      'alert-success' # Blue
    when :info
      'alert-info' # Blue
    else
      flash_type.to_s
    end
  end

  def show_flash(type, message)
    klass = bootstrap_class_for(type)

    content_tag(:div, class: "alert alert-dismissible fade in #{klass} flash-message", role: 'alert') do
      concat(button_tag(type: 'button', class: 'close', data: { dismiss: 'alert', label: 'Close' }) do
        content_tag(:span, 'x', aria: { hidden: true })
      end)

      concat(message)
    end
  end

  def show_flashes(flash)
    flash.each do |type, message|
      if message.is_a?(Array)
        message.each do |text|
          show_flash(type, text)
        end

      else
        show_flash(type, message)
      end
    end
  end

  def page_title(text)
    title = t('application_name')
    text.blank? ? title : "#{title} - #{text}"
  end

  def nested_text_field(options = {})
    text_field_tag(options[:field_name], options[:value], type: :text, class: "form-control #{options[:class]}")
  end

  def nested_select(options = {})
    select_tag(options[:field_name], options[:value], class: "form-control tag-select #{options[:class]}")
  end

  def menu_item(path, icon, text, additional = {})
    options = { method: :get, remote: false }.merge(additional)

    content_tag(:li) do
      link_to path, method: options[:method], remote: options[:remote] do
        concat(content_tag(:i, '', class: "#{icon.split('-').first} #{icon}"))
        concat(text)
      end
    end
  end

  def log_out_menu_item(path, icon, text)
    menu_item(path, icon, text, method: :delete)
  end

  def icon_link(path, icon, text)
    link_to(path) do
      concat content_tag(:span, '', class: icon)
      concat ' '
      concat text
    end
  end

  def brand_link
    link_to(t('application_name'), authenticated_user_path, class: 'navbar-brand')
  end

  def link_image(image, options = {})
    link_to(image.url(:big), target: '_blank', title: options[:title]) do
      image_tag(image.url(:thumb), class: 'text-center img-circle', title: options[:title])
    end
  end

  def edit_link(destination)
    link_to(content_tag(:span, '', class: 'fa fa-pencil'), destination, class: 'pull-right')
  end

  def cancel_link(destination)
    round_icon_link(path: destination, type: :button, icon: 'fa-close', button: 'btn-default', class: 'pull-right m-l-5', title: t('wizard.button.cancel'))
  end

  def submit_link
    round_icon_button type: :submit, icon: 'fa-save', button: 'btn-success', class: 'pull-right', title: t('wizard.button.finish')
  end

  def round_icon_link(params)
    params[:method] ||= :get
    params[:remote] ||= false
    data = {}

    data[:confirm] = params[:confirm] if params[:confirm]

    link_to(params[:path], method: params[:method], data: data, remote: params[:remote]) do
      round_icon_button(params)
    end
  end

  def text_icon_link(params)
    params[:shape] = ''
    params[:text] = params[:title]
    params[:method] ||= :get
    params[:remote] ||= false
    data = {}

    data[:confirm] = params[:confirm] if params[:confirm]

    link_to(params[:path], method: params[:method], data: data, remote: params[:remote]) do
      text_icon_button(params)
    end
  end
end
