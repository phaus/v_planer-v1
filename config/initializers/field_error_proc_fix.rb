ActionView::Base.field_error_proc = proc do |html_tag, instance| 
  %(<span class="field-with-errors">#{html_tag}</span>).html_safe
end

