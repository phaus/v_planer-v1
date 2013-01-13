# encoding: utf-8

# Remove the rails error span from fields with errors.
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance_tag|
  html_tag
end

ActionView::Base.default_form_builder = Conforming::FormBuilder
