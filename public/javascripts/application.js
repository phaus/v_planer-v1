// needs functions imported from currency.js

function $pD(string) {
  return Date.parse(string.gsub('-', '/'));
}

function percent(val) {
  return Math.floor(val) + ',' + frac(val) + '&thinsp;%';
}

/*
  frac: helper function that formats a floating point number essentially
        the same way as sprintf('%.2f', val) would do in other languages
 */
function frac(val) {
  var val = Math.round((val % 1.0) * 100);
  if (val == 100)
    return '00';
  else if (val < 10)
    return  '0' + val;
  else
    return val;
}

function decimal(val) {
  return ('' + val).sub('.', ',');
}

function parseDecimal(string) {
  return parseFloat(string.gsub(',', '.'));
}

function date_changed(event) {
  rental.set('from_date', $pD($F('rental_begin')));
  rental.set('to_date', $pD($F('rental_end')));
  $('rental_usage_duration').value = rental.duration();
  rental_representation.usage_duration_changed(event);
}

function display_product_availability(event) {
  return false;

  var from_date = $F('rental_begin');
  var to_date   = $F('rental_end');

  $('available_products').hide();
  $('spinner').clonePosition('main_content');
  $('spinner').show();
  new Ajax.Request(Device.resource_url() + '/available', {
    parameters: 'from_date=' + from_date + '&to_date=' + to_date,
    method: 'get',
    on200: function(response) {
      var products_div = $('available_products');
      products_div.update(response.responseText);
      products_div.show();
      $('spinner').hide();
    },
    onFailure: function(response) {
      $('available_products').update(response.responseText);
      $('available_products').show();
      $('spinner').hide();
      rental_table_changed();
    }
  });
}

function show_or_hide_fieldset(event) {
  var input = event.element();
  var content = input.up('fieldset').down('div.optional-fieldset-content');
  if (input.checked) {
    content.select('input', 'select', 'textarea').invoke('enable');
    content.show();
  } else {
    content.select('input', 'select', 'textarea').invoke('disable');
    content.hide();
  }
}

function show_or_hide_fieldsets(event) {
  $$('fieldset.optional-fieldset').each(function(fieldset) {
    var input = fieldset.down('input[type=checkbox]');
    input.observe('change', show_or_hide_fieldset);
    var content = input.up('fieldset').down('div.optional-fieldset-content');
    if (input.checked) {
      content.show();
    } else {
      content.hide();
    }
  });
}

document.observe('dom:loaded', show_or_hide_fieldsets);

function insert_new_item_in_process_table(search_input, li) {
  search_input.value = '';
  var element = li.down('.new_row_for_form table tr');
  search_input.up('tr').insert({before: element});
  selling_representation.register_item(element);
  with (element.down('.count input')) {
    focus();
    value = 1;
  }
  li.up('ul').remove();
}

