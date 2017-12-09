
module Base::Project::App::Helpers::ButtonHelper
  def command_button( path, row_id, message, additional = { } )
    options = { remote: false, role: :get, target: '_self', klass: '',
                text: "", confirm: false, data: { } }.merge( additional )

    text             = options[:text]
    role             = options[:role]
    icon             = options[:icon]
    klass            = options[:klass]
    is_remote        = options[:remote]
    html_data        = options[:data]

    data_params = html_data.merge( { toggle: 'tooltip', placement: 'top', 'row-id': row_id, 'original-title': message } )
    data_params[:confirm] = I18n.t('confirmation') if options[:confirm]

    button = command_button_item( klass, icon, text, data_params )

    if path.present?
      link_to(path, remote: is_remote, data: data_params, target: options[:target], method: role) do
        concat( button )
      end

    else
      button
    end
  end

  def command_button_item( klass, icon, text, data )
    text = " #{text}" if text.present?

    button_tag( role: 'button', type: 'button', class: "btn btn-primary #{ klass }", data: data ) do
      content_tag( :span, text, class: icon )
    end
  end

  def edit_button( path, row_id, message, additional = { } )
    options = { role: :get, icon: 'zmdi zmdi-edit' }.merge( additional )
    command_button( path, row_id, I18n.t('simple_form.edit', message: message), options )
  end

  def new_button( path, message, additional = { } )
    options = { role: :get, icon: 'zmdi zmdi-plus' }.merge( additional )
    command_button( path, 0, I18n.t('simple_form.new', message: message), options )
  end

  def delete_button( path, row_id, message, additional = { } )
    options = { role: :delete, icon: 'zmdi zmdi-delete', klass: 'command-delete', confirm: true }.merge( additional )
    command_button( path, row_id, I18n.t('simple_form.delete', message: message), options )
  end

  def show_button( path, row_id, message, additional = { } )
    options = { role: :get, icon: 'zmdi zmdi-search' }.merge( additional )
    command_button( path, row_id, I18n.t('simple_form.show', message: message), options )
  end

  def open_filter_button
     button_tag( t('simple_form.filter'), id: 'enable-filter',
                 class: 'btn btn-regular pull-left' )
  end

  def do_filter_button
     button_tag( t('simple_form.search'), id: 'enable-filter',
                 class: 'btn btn-primary pull-right' )
  end

  def cancel_button
    round_icon_button(type: :button, icon: 'fa-close', button: 'btn-default', class: 'pull-right', title: 'Cancelar')
  end

  def round_icon_button(params)
    params[:shape] = 'btn-circle'
    params[:text] = ''

    text_icon_button(params)
  end

  def text_icon_button(params)
    params[:size] ||= 'btn-lg'

    content = content_tag(:span) do
      concat(content_tag(:span, '', class: "fa #{params[:icon]}"))
      concat(" #{params[:text]}") if params[:text] && params[:text].length > 0
    end

    button_data = { type: params[:type],
                    class: "btn #{params[:button]} #{params[:shape]} #{params[:size]} #{params[:class]} text-center",
                    title: params[:title],
                    data: {
                      toggle: 'tooltip',
                      placement: 'bottom'
                    }
                  }


    button_data[:id] = params[:id] if params[:id]
    button_data[:data] = button_data[:data].merge(params[:data]) if params[:data]

    button_tag(content, button_data)
  end
end
