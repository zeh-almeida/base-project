
module PanelHelper
  def do_panel(params, &block)
    params[:block] = block
    params[:color] ||= 'panel-primary'
    render 'shared/panels/panel', params
  end
end
