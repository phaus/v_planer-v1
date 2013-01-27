var Rental = ActiveResource.inherit({
  belongs_to: {
    client: {
      class_name: 'Client'
    }
  },

  has_many: {
    rental_periods: {
      class_name: 'RentalPeriod'
    },
    service_items: {
      class_name: 'ServiceItem'
    }
  },

  resource: 'rentals',

  discount_rates: {
      0: 0.0,
      1: 1.0,
      2: 1.65,
      3: 2.3,
      4: 2.95,
      5: 3.35,
      6: 3.75,
      7: 4.15,
      8: 4.55,
      9: 4.95,
     10: 5.0
  },

  sum: function() {
    var amount = 0;
    this.rental_periods().each(function(rp) {
      amount = amount + rp.price().cents;
    });
    this.service_items().each(function(rp) {
      amount = amount + rp.price().cents;
    });
    return $M(amount);
  },

  discount: function() {
    if (this.get('discount')) {
      return this.get('discount');
    } else if (this.get('discount_i')) {
      return $M(this.get('discount_i'));
    } else {
      return $M(0);
    }
  },

  client_discount: function() {
    if (this.get('client_discount')) {
      return this.get('client_discount');
    } else if (this.get('client_discount_i')) {
      return $M(this.get('client_discount_i'));
    } else if (this.client()) {
      return $M((this.client().get('discount_i') / 100.0) * this.sum().cents);
    } else {
      return $M(0);
    }
  },

  reset_to_default_client_discount: function() {
    this.set('client_discount_percent', null);
    this.set('client_discount', null);
    this.set('client_discount_i', null);
  },

  client_discount_percent: function() {
    var sum = this.sum().cents;
    if (this.get('client_discount')) {
      if (sum != 0) {
        return 100.0 * this.client_discount().cents / sum;
      } else {
        return 0.0;
      }
    } else if (this.client()) {
      return this.client().discount();
    } else {
      return 0.0;
    }
  },

  billed_duration: function() {
    if (this.get('billed_duration') == 0) return 0;
    return (this.get('billed_duration') || this.discount_rates[this.get('usage_duration')]);
  },

  net_total_price: function() {
    return $M(this.sum().cents - this.client_discount().cents - this.discount().cents);
  },

  gross_total_price: function() {
    return $M(this.net_total_price().cents + this.vat().cents);
  },

  vat: function() {
    return $M(this.net_total_price().cents * 19.0 / 100.0);
  },

  duration: function() {
    if (this.get('from_date') == this.get('to_date'))
      return 1;
    else
      return (this.get('to_date') - this.get('from_date')) / 86400000;
  },

  set_client_id: function(id) {
    this.set('client_id', id);
    this.client(true);
  }
});


var RentalRepresentation = Class.create({
  initialize: function(process, dom_object) {
    this.in_init_phase = true;
    this.process       = process;
    this.dom_object    = dom_object;
    this.register_event_handlers();
    this.process.set('client_id',       $F('rental_client_id'));
    this.process.set('usage_duration',  parseDecimal($F('rental_usage_duration')));
    this.process.set('billed_duration', parseDecimal($F('rental_billed_duration')));
    this.process.set('from_date',       $pD($F('rental_begin')));
    this.process.set('to_date',         $pD($F('rental_end')));
    this.process.set('discount',        $pM($F('rental_discount')));
    this.process.set('client_discount', $pM($F('rental_client_discount')));

    this.register_items();
    $('rental_offer_top_text').update(this.process.get('offer_top_text'));
    $('rental_offer_bottom_text').update(this.process.get('offer_bottom_text'));
    this.in_init_phase = false;
    this.table_changed();
  },

  discount_changed: function(event) {
    var element  = event.element();
    if ($F(element) == '')
      var discount = $M(0);
    else
      var discount = $pM($F(element));
    this.process.set('discount', discount);
    element.value = discount.to_val();
    this.table_changed();
  },

  usage_duration_changed: function(event) {
    var element = $('rental_usage_duration');
    if (element.value == '') {
      element.value = this.process.duration();
    }
    var usage_duration = parseDecimal($F(element));
    if (usage_duration > 10) {
      alert('Bitte geben Sie von Hand eine Abrechnungsdauer ein.');
      element.removeClassName('fieldWithErrors');
    } else if (usage_duration < 0.0) {
      alert('Bitte geben Sie eine gültige Gebrauchsdauer ein.');
      element.addClassName('fieldWithErrors');
      element.value = '';
      element.focus();
      return false;
    } else {
      element.removeClassName('fieldWithErrors');
    }
    this.process.set('usage_duration', usage_duration);
    this.process.set('billed_duration', null);
    if (this.process.billed_duration() != undefined)
      $('rental_billed_duration').value = this.process.billed_duration();
    else
      $('rental_billed_duration').value = '';
    this.rental_period_representations.invoke('billed_duration_changed');
    this.table_changed();
  },

  billed_duration_changed: function(event) {
    var element         = event.element();
    var usage_duration  = this.process.get('usage_duration');
    var billed_duration = parseDecimal(element.value);
    if (element.value == '') {
      this.process.set('billed_duration', null);
      if (usage_duration > 10) {
        alert('Bitte geben Sie von Hand eine Abrechnungsdauer ein.');
        element.focus();
      } else {
        element.value = this.process.billed_duration(); // set calculated billed_duration
      }
    } else if (billed_duration < 0) {
      alert('Die eingegebene Abrechnungsdauer (Staffelung) ist negativ!');
      element.addClassName('fieldWithErrors');
      element.value = '';
      element.focus();
    } else if (billed_duration > this.process.get('usage_duration')) {
      alert('Die Abrechnungsdauer ('+billed_duration +') ist länger als die Gebrauchsdauer ('+usage_duration+') -- ist das nicht unfair?');
      element.addClassName('fieldWithErrors');
      element.value = '';
      element.focus();
    } else {
      element.removeClassName('fieldWithErrors');
    }
    this.process.set('billed_duration', billed_duration);
    this.rental_period_representations.invoke('billed_duration_changed');
    this.table_changed();
  },

  client_discount_changed: function(event) {
    var element = $('rental_client_discount');
    if (element.value == '') {
      this.process.reset_to_default_client_discount();
    } else {
      this.process.set('client_discount', $pM($F(element)));
    }
    this.table_changed();
  },

  table_changed: function() {
    this.dom_object.down('.rental.sum').update(this.process.sum().to_s());
    this.dom_object.down('.rental.discount input').value = this.process.discount().to_val();
    this.dom_object.down('.rental.client_discount input').value = this.process.client_discount().to_val();
    this.dom_object.down('.rental.client_discount_percent').update(percent(this.process.client_discount_percent()));
    this.dom_object.down('.rental.net_total_price').update(this.process.net_total_price().to_s());
    this.dom_object.down('.rental.vat').update(this.process.vat().to_s());
    this.dom_object.down('.rental.gross_total_price input').value = this.process.gross_total_price().to_val();
    if (this.process.get('usage_duration'))
      this.dom_object.show();
    else
      this.dom_object.hide();
  },

  gross_total_price_changed: function(event) {
    var element = event.element();
    var gross_total_price = $pM($F(element));
    if (gross_total_price == null) {
      gross_total_price = this.process.gross_total_price().to_val();
    } else if (gross_total_price < 0) {
      alert('Der Brutto-Gesamtpreis soll doch nicht etwa weniger als 0,00&thinsp;&euro; betragen?!');
      return false;
    } else {
      var net_total_price   = $M(gross_total_price.cents / 1.19);
      var discount          = $M(this.process.sum().cents - this.process.client_discount().cents - net_total_price.cents);
    }
    this.process.set('discount', discount);
    this.table_changed();
  },

  client_id_changed: function(event) {
    alert('client_id changed');
    var element = event.element();
    if (this.process) {
      this.process.set_client_id($F(element));
      this.table_changed();
    }
  },

  change_handlers: {},

  register_event_handlers: function() {
    this.change_handlers.client_id         = this.client_id_changed.bindAsEventListener(this);
    this.change_handlers.client_discount   = this.client_discount_changed.bindAsEventListener(this);
    this.change_handlers.discount          = this.discount_changed.bindAsEventListener(this);
    this.change_handlers.usage_duration    = this.usage_duration_changed.bindAsEventListener(this);
    this.change_handlers.billed_duration   = this.billed_duration_changed.bindAsEventListener(this);
    this.change_handlers.gross_total_price = this.gross_total_price_changed.bindAsEventListener(this);

    $('rental_client_id').observe('change',         this.change_handlers.client_id);
    $('rental_client_discount').observe('change',   this.change_handlers.client_discount);
    $('rental_discount').observe('change',          this.change_handlers.discount);
    $('rental_usage_duration').observe('change',    this.change_handlers.usage_duration);
    $('rental_billed_duration').observe('change',   this.change_handlers.billed_duration);
    $('rental_gross_total_price').observe('change', this.change_handlers.gross_total_price);
  },

  register_items: function() {
    var self = this;
    this.rental_period_representations = []
    this.service_item_representations  = []
    if (!this.process.new_record) {
      // load items into cache
      this.process.rental_periods();
      this.process.service_items();
    }
    $$('tr.product.device').each(function(tr) {
      self.register_device_item(tr);
    });
    $$('tr.product.service').each(function(tr) {
      self.register_service_item(tr);
    });
  },

  register_service_item: function(dom_object) {
    var opt_rp_id = dom_object.down('td.product_id input[type=hidden]', 1);
    if (opt_rp_id && opt_rp_id.value) {
      var rp = this.process.service_item(opt_rp_id.value);
    } else {
      var rp = new ServiceItem();
      this.process.service_items().push(rp);
    }

    var rpp = new ServiceItemRepresentation(rp, dom_object, this);
    rp.set('process', this.process);
    this.service_item_representations.push(rpp);
    if (rpp.dom_object.down('.count input').value <= 0)
      rpp.dom_object.down('.count input').value = 1;
    rpp.count_changed(null);
  },

  register_device_item: function(dom_object) {
    var opt_rp_id = dom_object.down('td.product_id input[type=hidden]', 1);
    if (opt_rp_id && opt_rp_id.value) {
      var rp = this.process.rental_period(opt_rp_id.value);
    } else {
      var rp = new RentalPeriod();
      this.process.rental_periods().push(rp);
    }

    var rpp = new RentalPeriodRepresentation(rp, dom_object, this);
    rp.set('process', this.process);
    this.rental_period_representations.push(rpp);
    if (rpp.dom_object.down('.count input').value <= 0)
      rpp.dom_object.down('.count input').value = 1;
    rpp.count_changed(null);
  },

  register_item_with_new_product: function(dom_object) {
    var opt_rp_id = dom_object.down('td.product_id input[type=hidden]', 1);
    var rp = new RentalPeriod();
    rp.set('product', new Product());
    rp.set('process', this.process);
    this.process.rental_periods().push(rp);

    var rpp = new RentalPeriodWithNewProductRepresentation(rp, dom_object, this);
    this.rental_period_representations.push(rpp);

    if (parseInt(rpp.dom_object.down('.count input').value) <= 0)
      rpp.dom_object.down('.count input').value = 1;
    if (parseInt(rpp.dom_object.down('.available_count input').value) <= 0)
      rpp.dom_object.down('.available_count input').value = 1;
    rpp.count_changed(null);
  },

  remove_item: function(item) {
    if (item.dom_object.hasClassName('service')) {
      this.servic_item_representations = this.service_item_representations.without(item);
      item.service_item.set('count', 0);
    } else {
      this.rental_period_representations = this.rental_period_representations.without(item);
      item.rental_period.set('count', 0);
    }
    this.table_changed();
  }

});
