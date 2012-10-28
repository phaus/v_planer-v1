var ServiceItem = ActiveResource.inherit({
  belongs_to: {
    'product': {
      class_name: 'Product'
    },
    'client': {
      class_name: 'Client'
    }
  },

  resource: 'service_items',

  process: function() {
    return this.get('process');
  },

  price: function() {
    var stored_price = this.get('price');
    if (stored_price)
      return $M(stored_price);
    else
      return $M(this.duration() * this.get('count') * this.unit_price().cents);
  },

  duration: function() {
    return this.get('duration') || 0.0;
  },

  is_service: function() {
    return true;
  },

  unit_price: function() {
    if (this.get('unit_price')) {
      return this.get('unit_price');
    } else if (this.get('price')) {
      return $M(this.get('price').cents / (this.duration() * this.get('count')));
    } else if (this.get('unit_price_i')) {
      return $M(this.get('unit_price_i'));
    } else if (pr = this.new_or_existing_product()) {
      return pr.unit_price();
    } else {
      return $M(0);
    }
  },

  new_or_existing_product: function() {
    return this.get('product') || this.product();
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
  },

  change_duration: function(new_duration) {
    this.set('duration', new_duration);
    this.set('price', null);
    this.set('price', this.price());
  }

});


var ServiceItemRepresentation = Class.create({

  initialize: function(service_item, dom_object, process) {
    this.process      = process;
    this.service_item = service_item;
    this.dom_object   = dom_object;

    if (this.service_item.new_record) {
      // take values from the form
      this.service_item.set('product_id', $F(this.dom_object.down('.product_id input')));
      this.service_item.set('count', parseDecimal($F(this.dom_object.down('.count input'))));
      this.service_item.set('duration', parseDecimal($F(this.dom_object.down('.duration input'))));
    } else {
      // take values from the model
      this.dom_object.down('.product_id input').value = this.service_item.get('product_id');
      this.dom_object.down('.count input').value      = this.service_item.get('count');
      this.dom_object.down('.duration input').value   = this.service_item.get('duration');
    }
    this.dom_object.down('.unit_price input').value = this.service_item.unit_price().to_val();
    this.dom_object.down('.price input').value      = this.service_item.price().to_val();
    this.register_event_handlers();
  },

  model_changed: function() {
    if (!this.process.in_init_phase) {
      this.process.table_changed();
    }
  },

  // called from process object when the billed duration was changed
  billed_duration_changed: function() {
    this.dom_object.down('.price input').value = this.service_item.price().to_val();
  },

  count_changed: function(event) {
    var element = this.dom_object.down('.count input');
    var count   = parseDecimal($F(element));
    this.service_item.change_count(count);
    this.dom_object.down('.price input').value = this.service_item.price().to_val();
    this.model_changed();
  },

  price_changed: function(event) {
    var element = this.dom_object.down('.price input');
    var price = $pM($F(element));
    if (price == null) {
      this.service_item.reset_price()
    } else {
      this.service_item.change_price(price);
    }
    this.dom_object.down('.item.price input').value = this.service_item.price().to_val();
    this.dom_object.down('.item.unit_price input').value = this.service_item.unit_price().to_val();
    this.model_changed();
  },

  unit_price_changed: function(event) {
    var element = this.dom_object.down('.unit_price input');
    var unit_price = $pM($F(element));
    if (unit_price != null) {
      this.service_item.change_unit_price(unit_price);
      element.value = unit_price.to_val();
    }
    element.value = this.service_item.unit_price().to_val();
    this.dom_object.down('.item.price input').value = this.service_item.price().to_val();
    this.model_changed();
  },

  duration_changed: function(event) {
    var element = this.dom_object.down('.duration input');
    var duration = parseDecimal($F(element));
    if (duration == null) {
      element.value = 0;
    } else {
      this.service_item.change_duration(duration);
    }
    this.dom_object.down('.item.price input').value = this.service_item.price().to_val();
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

  event_handlers: {},

  register_event_handlers: function() {
    this.event_handlers.count       = this.count_changed.bindAsEventListener(this);
    this.event_handlers.price       = this.price_changed.bindAsEventListener(this);
    this.event_handlers.unit_price  = this.unit_price_changed.bindAsEventListener(this);
    this.event_handlers.duration    = this.duration_changed.bindAsEventListener(this);
    this.event_handlers.remove_item = this.remove_button_pressed.bindAsEventListener(this);
    this.dom_object.down('.item.count input').observe('change', this.event_handlers.count);
    this.dom_object.down('.item.price input').observe('change', this.event_handlers.price);
    this.dom_object.down('.item.duration input').observe('change', this.event_handlers.duration);
    this.dom_object.down('.item.unit_price input').observe('change', this.event_handlers.unit_price);
    if (remove_button = this.dom_object.down('button.remove_line')) {
      remove_button.observe('click', this.event_handlers.remove_item);
    }
  },

  unregister_event_handlers: function() {
    this.dom_object.down('.item.count input').stopObserving('change', this.event_handlers.count);
    this.dom_object.down('.item.price input').stopObserving('change', this.event_handlers.price);
    this.dom_object.down('.item.unit_price input').stopObserving('change', this.event_handlers.unit_price);
    this.dom_object.down('.item.duration input').stopObserving('change', this.event_handlers.duration);
    this.dom_object.down('button.remove_line').stopObserving('click', this.event_handlers.remove_item);
  }

});

// var RentalPeriodWithNewProductRepresentation = Class.create({
//
//   initialize: function(service_item, dom_object, process) {
//     this.process      = process;
//     this.product      = service_item.get('product');
//     this.service_item = service_item;
//     this.dom_object   = dom_object;
//
//     this.product.set('name',            $F(this.dom_object.down('input.product_name')));
//     this.product.set('description',     $F(this.dom_object.down('textarea.product_description')));
//     this.product.set('unit_price',      $pM($F(this.dom_object.down('.unit_price input'))));
//
//     this.service_item.set('duration',   $F(this.dom_object.down('.duration input')));
//     this.service_item.set('count',      parseDecimal($F(this.dom_object.down('.count input'))));
//     this.service_item.set('unit_price', $pM($F(this.dom_object.down('.unit_price input'))));
//     this.service_item.set('price',      $pM($F(this.dom_object.down('.price input'))));
//
//     this.dom_object.down('.unit_price input').value = this.service_item.unit_price().to_val();
//     this.dom_object.down('.price input').value      = this.service_item.price().to_val();
//     this.register_event_handlers();
//   },
//
//   model_changed: function() {
//     if (!this.process.in_init_phase) {
//       this.process.table_changed();
//     }
//   },
//
//   // called from process object when the billed duration was changed
//   // but we don't care, since service items are not dependent on the rental duration
//   billed_duration_changed: function() {},
//
//   count_changed: function(event) {
//     var element = this.dom_object.down('.count input');
//     var count   = parseDecimal($F(element));
//     this.service_item.set('unit_price', this.service_item.unit_price());  // keep a possibly calculated unit price
//     this.service_item.set('count', count); // set the new count
//     this.service_item.set('price', null);  // force recalculation of price
//     this.dom_object.down('.price input').value = this.service_item.price().to_val();
//     var deleter = this.dom_object.down('input._destroy');
//     if (deleter) {
//       if (count == 0)
//         deleter.value = 1;
//       else
//         deleter.value = 0;
//     }
//     this.model_changed();
//   },
//
//   price_changed: function(event) {
//     var element = this.dom_object.down('.price input');
//     var price = $pM($F(element));
//     if (price == null) {
//       this.service_item.set('price', null);
//       this.dom_object.down('.item.price input').value = this.service_item.price().to_val();
//     } else {
//       this.service_item.set('price', price);
//       this.service_item.set('unit_price', null);
//       element.value = price.to_val();
//       this.dom_object.down('.item.unit_price input').value = this.service_item.unit_price().to_val();
//     }
//     this.model_changed();
//   },
//
//   unit_price_changed: function(event) {
//     var element = this.dom_object.down('.unit_price input');
//     var unit_price = $pM($F(element));
//     if (unit_price == null) {
//       element.value = this.service_item.unit_price().to_val(); // get the default price from product
//     } else {
//       this.service_item.set('unit_price', unit_price);
//       this.service_item.set('price', null);
//       element.value = unit_price.to_val();
//     }
//     this.dom_object.down('.item.price input').value = this.service_item.price().to_val();
//     this.model_changed();
//   },
//
//   duration_changed: function(event) {
//     var element = this.dom_object.down('.duration input');
//     var duration = parseDecimal($F(element));
//     if (duration == null) {
//       element.value = 0;
//     } else {
//       this.service_item.set('duration', duration);
//       this.service_item.set('price', null);
//     }
//     this.dom_object.down('.item.price input').value = this.service_item.price().to_val();
//     this.model_changed();
//   },
//
//   remove_button_pressed: function(event) {
//     event.stop();
//     this.unregister_event_handlers();
//     this.dom_object.remove();
//     this.process.remove_item(this);
//   },
//
//   event_handlers: {},
//
//   register_event_handlers: function() {
//     this.event_handlers.count       = this.count_changed.bindAsEventListener(this);
//     this.event_handlers.price       = this.price_changed.bindAsEventListener(this);
//     this.event_handlers.unit_price  = this.unit_price_changed.bindAsEventListener(this);
//     this.event_handlers.duration    = this.duration_changed.bindAsEventListener(this);
//     this.event_handlers.remove_item = this.remove_button_pressed.bindAsEventListener(this);
//     this.dom_object.down('.item.count input').observe('change', this.event_handlers.count);
//     this.dom_object.down('.item.price input').observe('change', this.event_handlers.price);
//     this.dom_object.down('.item.unit_price input').observe('change', this.event_handlers.unit_price);
//     this.dom_object.down('.item.duration input').observe('change', this.event_handlers.duration);
//     this.dom_object.down('button.remove_line').observe('click', this.event_handlers.remove_item);
//   },
//
//   unregister_event_handlers: function() {
//     this.dom_object.down('.item.count input').stopObserving('change', this.event_handlers.count);
//     this.dom_object.down('.item.price input').stopObserving('change', this.event_handlers.price);
//     this.dom_object.down('.item.unit_price input').stopObserving('change', this.event_handlers.unit_price);
//     this.dom_object.down('.item.duration input').stopObserving('change', this.event_handlers.duration);
//     this.dom_object.down('button.remove_line').stopObserving('click', this.event_handlers.remove_item);
//   }
//
// });
