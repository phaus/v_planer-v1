var RentalPeriod = ActiveResource.inherit({
  belongs_to: {
    'product': {
      class_name: 'Product'
    },
    'client': {
      class_name: 'Client'
    }
  },

  resource: 'rental_periods',

  process: function() {
    return this.get('process');
  },

  price: function() {
    if (this.get('price'))
      return $M(this.get('price'));
    else if (this.is_service())
      return $M(this.unit_price().cents * this.get('count'));
    else
      return $M(this.unit_price().cents * this.get('count') * this.billed_duration());
  },

  is_service: function() {
    return false
  },

  unit_price: function() {
    if (this.get('unit_price')) {
      return this.get('unit_price');
    } else if (this.get('price')) {
      if (this.is_service())
        return $M(this.price().cents / (this.billed_duration() * this.get('count')));
      else
        return $M(this.price().cents / this.get('count'));
    } else if (this.get('unit_price_i')) {
      return $M(this.get('unit_price_i'));
    } else if (pr = this.new_or_existing_product()) {
      if (pr.is_service())
        return pr.unit_price();
      else
        return pr.rental_price();
    } else {
      return $M(0);
    }
  },

  billed_duration: function() {
    return (this.process() ? this.process().billed_duration() : 0);
  },

  new_or_existing_product: function() {
    return this.get('product') || this.product();
  }

});


var RentalPeriodRepresentation = Class.create({

  initialize: function(rental_period, dom_object, process) {
    this.process       = process;
    this.rental_period = rental_period;
    this.dom_object    = dom_object;

    if (this.rental_period.new_record) {
      // take values from the form
      this.rental_period.set('product_id', $F(this.dom_object.down('.product_id input')));
      this.rental_period.set('count', parseDecimal($F(this.dom_object.down('.count input'))));
    } else {
      // take values from the model
      this.dom_object.down('.product_id input').value = this.rental_period.get('product_id');
      this.dom_object.down('.count input').value      = this.rental_period.get('count');
    }
    this.dom_object.down('.unit_price input').value = this.rental_period.unit_price().to_val();
    this.dom_object.down('.price input').value      = this.rental_period.price().to_val();
    this.register_event_handlers();
  },

  model_changed: function() {
    if (!this.process.in_init_phase) {
      this.process.table_changed();
    }
  },

  // called from process object when the billed duration was changed
  billed_duration_changed: function() {
    this.dom_object.down('.price input').value = this.rental_period.price().to_val();
  },

  count_changed: function(event) {
    var element = this.dom_object.down('.count input');
    var count   = parseDecimal($F(element));
    this.rental_period.set('unit_price', this.rental_period.unit_price());  // keep a possibly calculated unit price
    this.rental_period.set('count', count); // set the new count
    this.rental_period.set('price', null);  // force recalculation of price
    this.dom_object.down('.price input').value = this.rental_period.price().to_val();
    var deleter = this.dom_object.down('input._delete');
    if (deleter) {
      if (count == 0)
        deleter.value = 1;
      else
        deleter.value = 0;
    }
    this.model_changed();
  },

  price_changed: function(event) {
    var element = this.dom_object.down('.price input');
    var price = $pM($F(element));
    if (price == null) {
      this.rental_period.set('price', null);
      this.dom_object.down('.item.price input').value = this.rental_period.price().to_val();
    } else {
      this.rental_period.set('price', price);
      this.rental_period.set('unit_price', null);
      element.value = price.to_val();
      this.dom_object.down('.item.unit_price input').value = this.rental_period.unit_price().to_val();
    }
    this.model_changed();
  },

  unit_price_changed: function(event) {
    var element = this.dom_object.down('.unit_price input');
    var unit_price = $pM($F(element));
    if (unit_price == null) {
      element.value = this.rental_period.unit_price().to_val(); // get the default price from product
    } else {
      this.rental_period.set('unit_price', unit_price);
      this.rental_period.set('price', null);
      element.value = unit_price.to_val();
    }
    this.dom_object.down('.item.price input').value = this.rental_period.price().to_val();
    this.model_changed();
  },

  remove_button_pressed: function(event) {
    event.stop();
    this.dom_object.down('._delete').value = 1;
    this.dom_object.hide();
    this.process.remove_item(this);
  },

  event_handlers: {},

  register_event_handlers: function() {
    this.event_handlers.count       = this.count_changed.bindAsEventListener(this);
    this.event_handlers.price       = this.price_changed.bindAsEventListener(this);
    this.event_handlers.unit_price  = this.unit_price_changed.bindAsEventListener(this);
    this.event_handlers.remove_item = this.remove_button_pressed.bindAsEventListener(this);
    this.dom_object.down('.item.count input').observe('change', this.event_handlers.count);
    this.dom_object.down('.item.price input').observe('change', this.event_handlers.price);
    this.dom_object.down('.item.unit_price input').observe('change', this.event_handlers.unit_price);
    if (remove_button = this.dom_object.down('button.remove_line')) {
      remove_button.observe('click', this.event_handlers.remove_item);
    }
  },

  unregister_event_handlers: function(){
    this.dom_object.down('.item.count input').stopObserving('change', this.event_handlers.count);
    this.dom_object.down('.item.price input').stopObserving('change', this.event_handlers.price);
    this.dom_object.down('.item.unit_price input').stopObserving('change', this.event_handlers.unit_price);
    this.dom_object.down('button.remove_line').stopObserving('click', this.event_handlers.remove_item);
  }

});

var RentalPeriodWithNewProductRepresentation = Class.create({

  initialize: function(rental_period, dom_object, process) {
    this.process       = process;
    this.product       = rental_period.get('product');
    this.rental_period = rental_period;
    this.dom_object    = dom_object;

    this.product.set('name',            $F(this.dom_object.down('input.product_name')));
    this.product.set('description',     $F(this.dom_object.down('textarea.product_description')));
    this.product.set('available_count', $F(this.dom_object.down('.available_count input')));
    this.product.set('rental_price',    $pM($F(this.dom_object.down('.unit_price input'))));

    this.rental_period.set('count',      parseDecimal($F(this.dom_object.down('.count input'))));
    this.rental_period.set('unit_price', $pM($F(this.dom_object.down('.unit_price input'))));
    this.rental_period.set('price',      $pM($F(this.dom_object.down('.price input'))));

    this.dom_object.down('.unit_price input').value = this.rental_period.unit_price().to_val();
    this.dom_object.down('.price input').value      = this.rental_period.price().to_val();
    this.register_event_handlers();
  },

  model_changed: function() {
    if (!this.process.in_init_phase) {
      this.process.table_changed();
    }
  },

  // called from process object when the billed duration was changed
  billed_duration_changed: function() {
    this.dom_object.down('.price input').value = this.rental_period.price().to_val();
  },

  count_changed: function(event) {
    var element = this.dom_object.down('.count input');
    var count   = parseDecimal($F(element));
    this.rental_period.set('unit_price', this.rental_period.unit_price());  // keep a possibly calculated unit price
    this.rental_period.set('count', count); // set the new count
    this.rental_period.set('price', null);  // force recalculation of price
    this.dom_object.down('.price input').value = this.rental_period.price().to_val();
    var deleter = this.dom_object.down('input._delete');
    if (deleter) {
      if (count == 0)
        deleter.value = 1;
      else
        deleter.value = 0;
    }
    this.model_changed();
  },

  price_changed: function(event) {
    var element = this.dom_object.down('.price input');
    var price = $pM($F(element));
    if (price == null) {
      this.rental_period.set('price', null);
      this.dom_object.down('.item.price input').value = this.rental_period.price().to_val();
    } else {
      this.rental_period.set('price', price);
      this.rental_period.set('unit_price', null);
      element.value = price.to_val();
      this.dom_object.down('.item.unit_price input').value = this.rental_period.unit_price().to_val();
    }
    this.model_changed();
  },

  unit_price_changed: function(event) {
    var element = this.dom_object.down('.unit_price input');
    var unit_price = $pM($F(element));
    if (unit_price == null) {
      element.value = this.rental_period.unit_price().to_val(); // get the default price from product
    } else {
      this.rental_period.set('unit_price', unit_price);
      this.rental_period.set('price', null);
      element.value = unit_price.to_val();
    }
    this.dom_object.down('.item.price input').value = this.rental_period.price().to_val();
    this.model_changed();
  },

  remove_button_pressed: function(event) {
    event.stop();
    this.unregister_event_handlers();
    this.dom_object.remove();
    this.process.remove_item(this);
  },

  event_handlers: {},

  register_event_handlers: function() {
    this.event_handlers.count       = this.count_changed.bindAsEventListener(this);
    this.event_handlers.price       = this.price_changed.bindAsEventListener(this);
    this.event_handlers.unit_price  = this.unit_price_changed.bindAsEventListener(this);
    this.event_handlers.remove_item = this.remove_button_pressed.bindAsEventListener(this);
    this.dom_object.down('.item.count input').observe('change', this.event_handlers.count);
    this.dom_object.down('.item.price input').observe('change', this.event_handlers.price);
    this.dom_object.down('.item.unit_price input').observe('change', this.event_handlers.unit_price);
    this.dom_object.down('button.remove_line').observe('click', this.event_handlers.remove_item);
  },

  unregister_event_handlers: function() {
    this.dom_object.down('.item.count input').stopObserving('change', this.event_handlers.count);
    this.dom_object.down('.item.price input').stopObserving('change', this.event_handlers.price);
    this.dom_object.down('.item.unit_price input').stopObserving('change', this.event_handlers.unit_price);
    this.dom_object.down('button.remove_line').stopObserving('click', this.event_handlers.remove_item);
  }

});
