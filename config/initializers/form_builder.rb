module ActionView
  module Helpers
    module InstanceTagMethods
      DEFAULT_BUTTON_OPTIONS = {'type' => 'submit'}.freeze

      def to_button_tag(options = {})
        options = DEFAULT_BUTTON_OPTIONS.merge(options.stringify_keys)
        add_default_name_and_id(options)

        content_tag('button', options.delete('content'), options)
      end
    end
  end

end

class ConsolvingFormBuilder < ActionView::Helpers::FormBuilder

  def calendar_date_select(name, options = {})
    value = @object.send(name).to_s(:calendar_date_select) unless @object.send(name).nil?
    @template.text_field @object_name, name, options.merge(:class => 'calendar-date-select', :value => value)
  end

  def readonly_value(name, options = {})
    value = @object.send(name).to_s
    value = I18n.t('field.empty') if value.blank?
    @template.content_tag :span, value, options.merge(:class => 'input-value')
  end

  def attachment_value(options = {})
    value = @object.name.to_s
    value = I18n.t('field.empty') if value.blank?
    @template.content_tag :div, :class => 'attachment' do
      @template.link_to(value, @template.attachment_path(@object), options.merge(:title => "#{@object.name} (#{@object.size_in_kb}kB)")) +
      @template.content_tag(:span, :class => 'delete-attachment') do
        @template.check_box(@object_name, :_destroy, :value => 1) +
        @template.label(@object_name, :_destroy)
      end
    end
  end

  def button(method, options = {})
    options[:content] = yield if block_given?
    ActionView::Helpers::InstanceTag.new(@object_name, method, self, @object).to_button_tag(options)
  end

  def error_messages
    if @object.errors.any?
      @template.content_tag(:div, :class => 'errors') do
        @template.content_tag(:ul) do
          str = ''
          @object.errors.full_messages.each do |msg|
            str << @template.content_tag(:li, msg)
          end
          str.html_safe
        end
      end
    end
  end

  def unit_input(attr_name, unit, options = {})
    options = options.dup
    if options.delete(:check_calc) != false and @object.input_differs_from_calculation?(attr_name)
      calc_val = @object.calculated_value_for(attr_name).as_kg
      options['data-calculated-value'] = calc_val
      options[:title] = I18n.t('field.value differs from calculation') % {:calculated_value => "#{calc_val} kg"}
    end

    options['data-format'] ||= (options.delete(:format) || '%.1f')
    options[:value]        ||= @object.send("#{attr_name}_as_#{unit}")
    @template.text_field @object_name, "#{attr_name}_as_#{unit}", options
  end

  def calculatable_input(attr_name, options = {})
    options = options.dup
    if @object.input_differs_from_calculation?(attr_name)
      calc_val = @object.calculated_value_for(attr_name)
      options['data-calculated-value'] = calc_val
      options[:title] = I18n.t('field.value differs from calculation') % {:calculated_value => "#{calc_val}"}
    end

    options['data-format'] ||= options.delete(:format)

    options[:value] ||= @object.send(attr_name)
    @template.text_field @object_name, attr_name, options
  end

  def wrapped_readonly_value(attr_name, options = {})
    @template.content_tag :div, :class => 'field' do
      self.label(attr_name, options[:label]) +
      self.readonly_value(attr_name, options)
    end
  end

  def wrapped_text_field(attr_name, options = {})
    if @object.errors[attr_name].any?
      class_names = 'field with-error'
    else
      class_names = 'field'
    end
    error_msg = @object.errors[:attr_name].join('<br />')

    @template.content_tag :div, :class => class_names do
      text = @object.class.human_attribute_name(attr_name)
      self.label(attr_name, text, :title => error_msg) +
      @template.error_description_for(self, attr_name) +
      @template.text_field(@object_name, attr_name, options.merge(:title => error_msg, :value => @object.send(attr_name)))
    end
  end

  def wrapped_password_field(attr_name, options = {})
    if @object.errors[attr_name].any?
      class_names = 'field with-error'
    else
      class_names = 'field'
    end
    error_msg = @object.errors[:attr_name].join('<br />')

    @template.content_tag :div, :class => class_names do
      text = @object.class.human_attribute_name(attr_name)
      self.label(attr_name, text, :title => error_msg) +
      @template.error_description_for(self, attr_name) +
      @template.password_field(@object_name, attr_name, options.merge(:title => error_msg))
    end
  end

  def wrapped_date_selector_field(attr_name, options = {})
    if @object.errors[attr_name].any?
      class_names = 'field with-error'
    else
      class_names = 'field'
    end
    error_msg = @object.errors[:attr_name].join('<br />')
    options[:value] ||= @object.send(attr_name)

    @template.content_tag :div, :class => class_names do
      text = @object.class.human_attribute_name(attr_name)
      self.label(attr_name, text, :title => error_msg) +
      @template.error_description_for(self, attr_name) +
      @template.calendar_date_select(@object_name, attr_name, options.merge(:title => error_msg))
    end
  end

  def wrapped_unit_field(attr_name, unit, options)
    class_names = "field unit-#{unit} " + options[:class].to_s
    if @object.errors[attr_name].any?
      class_names << 'with-error'
    end
    field_name = "#{attr_name}_as_#{unit}"
    error_msg  = @object.errors[:attr_name].join('<br />')
    options[:value] ||= @object.send(field_name)

    @template.content_tag :div, :class => class_names do
      text = @object.class.human_attribute_name(field_name)
      self.label(field_name, text, :title => error_msg) +
      @template.error_description_for(self, attr_name) +
      self.unit_input(attr_name, unit, options.merge(:title => error_msg, :value => @object.send(field_name)))
    end
  end

  def submit_button(string, options = {})
    @template.content_tag :button, options.merge(:type => 'submit') do
      string
    end
  end

end

# Remove the rails error span from fields with errors.
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance_tag|
  html_tag
end

ActionView::Base.default_form_builder = ConsolvingFormBuilder

