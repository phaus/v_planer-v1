# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def partial_for(product, partial_name)
    "#{product.article_type.underscore.pluralize}/#{partial_name}"
  end

  def icon_for(type, object, options={})
    image_and_text = image_tag("icons_32/#{type}.png") + content_tag(:div, object.name, :class => 'name')
    content_tag :div,
      options[:link] ? link_to(image_and_text, object) : image_and_text,
      :class => "icon #{type}",
      :name  => "#{type}_#{object.id}"
  end

  def category_tabs(categories, opts={})
    str = ''
    categories.each do |category|
      str << category_navtab(link_to("#{category.name} (#{category.products.size})", url_for(:category_id => category)), :active => category.id == opts[:active].to_i)
    end
    unless params[:q].blank?
      str << category_navtab(link_to('Suchergebnis', devices_path(:q => params[:q])), :active => true)
    end
    str
  end

  def category_navtab(text, options={})
    active = options[:active] ? 'active' : ''
    <<-EOS
      <li class="#{active}">
          #{text}
      </li>
    EOS
  end

  def m(value)
    sprintf('%.2f&thinsp;&euro;', value||0).sub('.', ',')
  end

  def mv(value)
    sprintf('%.2f', value||0).sub('.', ',')
  end

  def hh(str)
    str.gsub(/\r?\n/, '<br />')
  end

  def ptm(value)
    sprintf('%.2f €', value||0).sub('.', ',')
  end

  def may_edit_client?(client=nil)
    true
  end

  def may_edit_products?
    is_company_admin?
  end

  def flash_message
    return if flash[:notice].blank?
    <<-EOS
      <p id="flash_message">#{flash[:notice]}</p>
      <script>$('flash_message').highlight().fade({duration: 2.0, delay: 4.0});</script>
    EOS
  end

  def javascript_on_load(&block)
    js_content = capture(&block).sub('<script>', '') rescue 'error in JS template!'
    content_for :javascript do
      javascript_tag "document.observe('dom:loaded', function() {#{js_content}});"
    end
  end

  def vat_applicable?
    not current_user.company_section.vat_id.blank?
  end

  def collection_checkboxes_for(form_builder, name, collection, name_method, value_method, options={}, html_options={})
    content_tag('fieldset', :class => 'multiple-select') do
      ''.tap do |str|
        str << content_tag('legend', options[:legend]) if options[:legend]
        form_builder.fields_for(name) do |check_boxes|
          collection.each do |object|
            str << content_tag('div', :class => 'select-option') do
              check_boxes.check_box(object.send(name_method), :checked => form_builder.object.send(name).include?(object.id)) +
                check_boxes.label(object.send(name_method), object.send(value_method))
            end
          end
        end
      end
    end
  end

  def optional_fieldset(legend, show_or_builder=false, field_name=nil,&block)
    form_builder = show_or_builder.is_a?(ActionView::Helpers::FormBuilder) ? show_or_builder : nil
    @@fieldset_counter ||= 0
    concat <<-EOS
            <div class="control-group">
    EOS
    if form_builder and field_name
    concat <<-EOS
          #{form_builder.label field_name, legend, :class => 'control-label'}
          <div class="controls">
            #{form_builder.check_box field_name}
          </div>
          </div>
    EOS
  else
    concat <<-EOS
          <label class="control-label" for="optional_fieldset_#{@@fieldset_counter}">#{legend}</label>
          <div class="controls">
            #{check_box_tag("optional_fieldset_#{@@fieldset_counter}", 1, show_or_builder)}
          </div>
          </div>
    EOS
  end
  concat <<-EOS
          #{capture(&block)}
  EOS
  @@fieldset_counter += 1
end

def public_footer
  <<-EOS
<footer class="footer">
  <div class="container">
            <p>powered by %{app_name}, the online commercial platform solution by <a target="_new" href="http://consolving.de">Consolving Network Solutions</a></p>
            <p>%{app_name} uses Ruby on Rails</p>
            <p>Copyright &copy; 2010-2013 Consolving Network Solutions GbR. All rights reserved. If you are interested in contributing to %{app_name} as a developer, please contact developer@consolving.de</p>
  </div>
  <div class="pull-right">
    <a href="http://jigsaw.w3.org/css-validator/">
      <img style="border:0;width:88px;height:31px"
           src="http://jigsaw.w3.org/css-validator/images/vcss-blue"
           alt="Valid CSS!" />
    </a>
    <a href="http://validator.w3.org/check?uri=referer">
      <img style="border:0;width:88px;height:31px"
           src="http://www.w3.org/Icons/valid-xhtml10-blue"
           alt="Valid XHTML 1.0 Transitional" />
    </a>
  </div>
</footer>
  EOS
end

def footer
  render :partial => 'layouts/footer'
end

  def last_changed_info(obj)
    str = ''
    if obj.updated_at == obj.created_at
      str << "<p>Erstellt am #{obj.created_at.to_date}</p>"
    end
    str << "<p>Zuletzt geändert am #{obj.updated_at.to_date}</p>"
    return str
  end

  def np(number, precision = 0, unit = '')
    str = number_with_precision(number, :precision => precision)
    unit.blank? ? str : "#{str} #{unit}"
  end
end
