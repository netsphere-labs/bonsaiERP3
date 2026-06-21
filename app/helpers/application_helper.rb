# encoding: utf-8 # author: Boris Barroso
# email: boriscyber@gmail.com
module ApplicationHelper
  # Checks if is set the organisation session
  # @return [True, False]
  #def organisation?
  #  session[:organisation] && session[:organisation].size > 0
  #end


  # Presens the logo of an organisation based on the session
  # @return [String]
  def organisation_logo
    session[:organisation][:name]
  end

  def active?(val)
    val ? 'Activo' : 'Inactivo'
  end

  # Creates an otion link
  # @param String text
  # @param String url
  # @param String option
  def link_option(text, option, options = {})
    options[:class] = "#{ options[:class] } #{( params[:option] === option ? 'active' : '' )}"
    url_hash = params.merge(:option => option)
    link_to text, url_for(url_hash), options
  end

=begin
  # Presents number to currency
  def ntc(val = nil, options = {})
    #number_to_currency(val.to_f, options)
    number_with_delimiter(val.to_f, t("number.format").merge(options))
  end
=end
  
  # Format addres to present on the
  def nl2br(val)
    unless val.blank?
      t = val.gsub("\n", '<br/>')
      t.html_safe
    end
  end


  def create_options_link
    opts = params
    opts.delete(:controller)
    opts.delete(:action)
    opts.inject("") do |s,(k,v)|
      sym = s.blank? ? '?' : '&'
      s << "#{sym}#{k}=#{v}"
    end
  end


  def tab(text, url, type)
    css = 'ui-state-default ui-corner-top'
    css << ' ui-tabs-selected ui-state-active' if type === params[:tab]
    content_tag(:li, link_to(text, url), :class => css)
  end

  def tab_panel
    content_tag(:div, class: 'ui-tabs-panel ui-widget-content ui-corner-bottom') do
      yield
    end
  end


  # @return [String]
  def edit_amount(n, curr_code)
    raise TypeError if curr_code && !curr_code.is_a?(String)
    return "" if !n

    exp = curr_code.blank? ? 0 : Money::Currency.find(curr_code).exponent
    if exp != 0
      # SQL decimal <-> Ruby BigDecimal
      (BigDecimal(n) / (10 ** exp)).to_s
    else
      n.to_s
    end
  end

  
  # @param curr_code [String] currency code
  def format_amount(n, curr_code)
    raise TypeError, "n must be Numeric, but #{n.class}" if !n.is_a?(Numeric)
    raise TypeError if curr_code && !curr_code.is_a?(String)

    exp = curr_code.blank? ? 0 : Money::Currency.find(curr_code).exponent
    n = BigDecimal(n.to_s) / (BigDecimal("10.0") ** exp) if exp != 0

    intpart, exppart = n.to_s.split('.', 2)
    intstr = intpart.reverse.split(/([0-9]{1,3})/).collect {|d| d == "" ? ',' : d}.join('').reverse.chop

    return (if exppart == ""
              intstr
            else
              sprintf("%s.%s", intstr, exppart)
            end)
  end

  
  # Presents a class with currency
  def with_currency(klass, amount = :amount, options = {})
    options = {:precision => 2}.merge(options)
    "#{number_to_currency klass.send(amount), options} <span class='labelz' title='#{klass.currency_name}'>#{klass.currency_code}</span>".html_safe
  end

  alias :wcur :with_currency


  def show_if_search
    if params[:search] || params[:search_div_id]
      'display:block'
    else
      'display:none'
    end
  end

  def selected_menu(page)
    "selected" if page == params[:page]
  end

  def inventory_operation_operation(io)
    if io.operation === "in"
      content_tag(:span, "ingreso", :class => "dark_green")
    else
      content_tag(:span, "egreso", :class => "red")
    end
  end

  # Get file with exchange_rates
  def set_exchange_rates
    file1 = Rails.root.join('public', 'exchange_rates.json')
    file2 = Rails.root.join('public', 'backup_rates.json')

    if not(File.exist?(file1)) || (File.ctime(file1) < Time.now - 4.hours)
      begin
        resp = ''
        Timeout.timeout(4) { resp = %x[curl http://openexchangerates.org/api/latest.json?app_id=e406e4769281493797fcfd45047773d5] }
        r = ActiveSupport::JSON.decode(resp)
        if r['rates'].present?
          f = File.new(file2, "w+")
          f.write(resp)
          f.close

          f = File.new(file1, "w+")
          f.write(resp)
          f.close
        else
          File.read(file2)
        end
      rescue Exception => e
        logger.warn "\n#Timeout::Error getting exchange_rates.json\n"  if e.is_a?(Timeout::Error)

        f = File.new(file1, 'w+')
        txt = File.read(file2)
        f.write txt
        f.close
        txt
      end
    else
      File.read(file2)
    end
  end

=begin
  def flash_class(fla)
    case fla.to_s
    when 'error'   then 'alert alert-error'
    when 'alert', :warning then 'alert alert-warning'
    when 'notice'  then 'alert alert-success'
    end
  end
=end
  
  def true_false(val)
    if val
      'icon-ok text-success'
    else
      'icon-remove text-error'
    end
  end

  def true_false_color(val)
    if val
      'icon-ok text-success'
    else
      'icon-remove text-error'
    end
  end

  def render_if(val, &block)
    content_tag(:span) { block.call } if val.present?
  end

  def bold_if(val)
    "b"  if val == true
  end

  def params_bold(val)
    params[val].present? ? 'b' : ''
  end

  def param_bold_for(key, val)
    params[key] == val ? 'b' : ''
  end

  def present_date_range(date_range)
    "del <i>#{I18n.l(date_range.date_start)}</i> al <i>#{I18n.l(date_range.date_end)}</i>".html_safe
  end

  # present search formated
  def search_tag
    if params[:search].present?
      content_tag(:span, params[:search], class: 'well pad2') do
        content_tag(:span, 'busqueda: ', class: 'muted') +
        content_tag(:strong, params[:search])
      end
    end
  end

  # Sets the path for search
  def set_search_path
    render 'layouts/set_search_path'
  end
end
