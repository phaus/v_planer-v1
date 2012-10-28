var SellingItem = ActiveResource.inherit({

  /* explanations:
   *
   * price_i: integer cent value sent from server; don't change!
   * price: price object calculated on client side -- may be changed
   * same applies to unit_price(_i)
   */

  belongs_to: {
    'product': {
      class_name: 'Product',
    },
    'client': {
      class_name: 'Client',
    }
  },

  resource: 'selling_items',

  selling: function() {
    return this.get('selling');
  },

  price: function() {
    var stored_price = this.get('price');
    if (stored_price)
      return $M(stored_price);
    else
      return $M(this.unit_price().cents * this.get('count'));
  },

  unit_price: function() {
    if (this.get('unit_price')) {
      return this.get('unit_price');
    } else if (this.get('price')) {
      return $M(this.get('price').cents / this.get('count'));
    } else if (this.get('unit_price_i')) {
      return $M(this.get('unit_price_i'));
    } else if (this.get('price_i')) {
      return $M(this.get('price_i') / this.get('count'));
    } else if (this.product()) {
      pr = this.product();
      return pr.selling_price();
    } else
      return $M(0);
  },

  change_price: function(new_price) {
    this.set('price', $M(new_price));
    this.set('unit_price', null);
    this.set('unit_price', this.unit_price());
  },

  reset_price: function() {
    this.set('price', null);
    this.set('unit_price', null);
  },

  change_unit_price: function(new_price) {
    this.set('unit_price', $M(new_price));
    this.set('price', null);
    this.set('price', this.price());
  },

  change_count: function(new_count) {
    this.set('count', new_count);
    this.set('price', null);
    this.set('price', this.price());
  }
});

var SellingItemRepresentation = Class.create({

  initialize: function(selling_item, dom_object, process, opts) {
    this.process      = process;
    this.selling_item = selling_item;
    if (dom_object.hasClassName('product'))
      this.dom_object = dom_object
    else
      this.dom_object = dom_object.down('tr');
    opts = opts ? opts : {read_from_form: false};
    if (!this.selling_item.product() || opts.read_from_form) {
      // take values from the form
      this.selling_item.set('product_id', $F(this.dom_object.down('.product_id input')));
      this.selling_item.set('count', parseDecimal($F(this.dom_object.down('.count input'))));
    } else {
      // take values from the model
      this.dom_object.down('.product_id input').value = this.selling_item.get('product_id');
      this.dom_object.down('.count input').value      = this.selling_item.get('count');
    }
    this.dom_object.down('.unit_price input').value = this.selling_item.unit_price().to_val();
    this.dom_object.down('.price input').value      = this.selling_item.price().to_val();
    this.register_event_handlers();
  },

  model_changed: function() {
    if (!this.process.in_init_phase) {
      this.process.table_changed();
    }
  },

  count_changed: function(event) {
    var element = this.dom_object.down('.count input');
    var count   = parseDecimal($F(element));
    this.selling_item.change_count(count);
    this.dom_object.down('.item.price input').value = this.selling_item.price().to_val();
    this.model_changed();
  },

  price_changed: function(event) {
    var element = this.dom_object.down('.price input');
    var price = $pM($F(element));
    if (price == null) {
      this.selling_item.reset_price();
    } else {
      this.selling_item.change_price(price);
    }
    element.value = this.selling_item.price().to_val();
    this.dom_object.down('.item.unit_price input').value = this.selling_item.unit_price().to_val();
    this.model_changed();
  },

  unit_price_changed: function(event) {
    var element = this.dom_object.down('.unit_price input');
    var unit_price = $pM($F(element));
    if (unit_price != null) {
      this.selling_item.change_unit_price(unit_price);
      element.value = unit_price.to_val();
    }
    element.value = this.selling_item.unit_price().to_val();
    this.dom_object.down('.item.price input').value = this.selling_item.price().to_val();
    this.model_changed();
  },

  remove_button_pressed: function(event) {
    event.stop();
    this.remove();
  },

  remove: function () {
    this.unregister_event_handlers();
    var delete_input = this.dom_object.down('._delete');
    if (delete_input == undefined) { // this is a newly added entry
      this.dom_object.remove();
    } else { // this is an existing entry
      delete_input.value = 1;
      this.dom_object.hide();
    }
    this.process.remove_item(this);
    if (this.product_info) {
      this.product_info.remove();
    }
  },

  reload_button_pressed: function(event) {
    event.stop();
    this.unregister_event_handlers();
    this.dom_object.remove();
    if (this.product_info) {
      this.product_info.remove();
    }

//     var self = this;
//     new Ajax.request(this.selling_item.product().url(), function(response) {
//       var dom_object = new Element('div').update(response.responseText);
//       self.initialize(self.selling_item, dom_object, self.process, {read_from_form: true});
//     });
  },

  product_link_clicked: function(event) {
    event.stop();
    if (this.product_info == null) {
      this.product_info = new ProductInfo(this.selling_item.product(), event.element());
    }
    this.product_info.show();
  },

  event_handlers: {},

  register_event_handlers: function() {
    this.event_handlers.count        = this.count_changed.bindAsEventListener(this);
    this.event_handlers.price        = this.price_changed.bindAsEventListener(this);
    this.event_handlers.unit_price   = this.unit_price_changed.bindAsEventListener(this);
    this.event_handlers.remove_item  = this.remove_button_pressed.bindAsEventListener(this);
    this.event_handlers.reload_item  = this.reload_button_pressed.bindAsEventListener(this);
    this.event_handlers.product_info = this.product_link_clicked.bindAsEventListener(this);

    this.dom_object.down('.item.count input').observe('change', this.event_handlers.count);
    this.dom_object.down('.item.price input').observe('change', this.event_handlers.price);
    this.dom_object.down('.item.unit_price input').observe('change', this.event_handlers.unit_price);
    if (remove_button = this.dom_object.down('button.remove_line')) {
      remove_button.observe('click', this.event_handlers.remove_item);
    }
    if (reload_button = this.dom_object.down('button.reload_line')) {
      reload_button .observe('click', this.event_handlers.reload_item);
    }
    if (product_info_link = this.dom_object.down('a')) {
      product_info_link.observe('click', this.event_handlers.product_info);
    }
  },

  unregister_event_handlers: function() {
    with(this.dom_object) {
      down('.item.count input').stopObserving('change', this.event_handlers.count);
      down('.item.price input').stopObserving('change', this.event_handlers.price);
      down('.item.unit_price input').stopObserving('change', this.event_handlers.unit_price);
      down('button.remove_line').stopObserving('click', this.event_handlers.remove_item);
      if (down('a.product_info')) {
        down('a.product_info').stopObserving('click', this.event_handlers.product_info);
      }
    }
  }

});



