var Selling = ActiveResource.inherit({
  belongs_to: {
    client: {
      class_name: 'Client'
    }
  },

  has_many: {
    device_items: {
      class_name: 'SellingItem'
    },
    service_items: {
      class_name: 'ServiceItem'
    }
  },

  resource: 'sellings',

  sum: function() {
    var amount = 0;
    this.device_items().each(function(item) {
      amount = amount + item.price().cents;
    });
    this.service_items().each(function(item) {
      amount = amount + item.price().cents;
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
      return $M((this.client().get('discount') / 100.0) * this.sum().cents);
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
        return 100.0 * this.get('client_discount').cents / sum;
      } else {
        return 0.0;
      }
    } else if (this.client()) {
      return this.client().get('discount');
    } else {
      return 0.0;
    }
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

  set_client_id: function(id) {
    this.set('client_id', id);
    this.client(true);
  }
});


var SellingRepresentation = Class.create({
  initialize: function(process, dom_object) {
    this.in_init_phase = true;
    this.process       = process;
    this.dom_object    = dom_object;
    this.register_event_handlers();
    this.process.set('client_id', $F('selling_client_id'));
    this.process.set('discount', $pM($F('selling_discount')));

    this.register_items();
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

  client_discount_changed: function(event) {
    var element = $('selling_client_discount');
    if (element.value == '') {
      this.process.reset_to_default_client_discount();
    } else {
      this.process.set('client_discount', $pM($F(element)));
    }
    this.table_changed();
  },

  table_changed: function() {
    this.dom_object.down('.selling.sum').update(this.process.sum().to_s());
    this.dom_object.down('.selling.discount input').value = this.process.discount().to_val();
    this.dom_object.down('.selling.client_discount input').value = this.process.client_discount().to_val();
    this.dom_object.down('.selling.client_discount_percent').update(percent(this.process.client_discount_percent()));
    this.dom_object.down('.selling.net_total_price').update(this.process.net_total_price().to_s());
    this.dom_object.down('.selling.vat').update(this.process.vat().to_s());
    this.dom_object.down('.selling.gross_total_price input').value = this.process.gross_total_price().to_val();
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
    var element = event.element();
    if (this.process) {
      this.process.set_client_id($F(element));
      this.table_changed();
    }
  },

  event_handlers: {},

  register_event_handlers: function() {
    this.event_handlers.client_id          = this.client_id_changed.bindAsEventListener(this);
    this.event_handlers.client_discount    = this.client_discount_changed.bindAsEventListener(this);
    this.event_handlers.discount           = this.discount_changed.bindAsEventListener(this);
    this.event_handlers.gross_total_price  = this.gross_total_price_changed.bindAsEventListener(this);

    $('selling_client_id').observe('change',         this.event_handlers.client_id);
    $('selling_client_discount').observe('change',   this.event_handlers.client_discount);
    $('selling_discount').observe('change',          this.event_handlers.discount);
    $('selling_gross_total_price').observe('change', this.event_handlers.gross_total_price);
  },

  register_items: function() {
    var self = this;
    this.device_item_representations  = [];
    this.service_item_representations = [];
    if (!this.process.new_record) {
      // load items into cache
      this.process.device_items();
      this.process.service_items();
    }
    $$('tr.product.device').each(function(tr) {
      self.register_device_item(tr);
    });
    $$('tr.product.service').each(function(tr) {
      self.register_service_item(tr);
    });
  },

  register_device_item: function(dom_object) {
    var opt_si_id = dom_object.down('td.product_id input[type=hidden]', 1);
    if (opt_si_id && opt_si_id.value) {
      var si = this.process.device_item(opt_si_id.value);
    } else {
      var si = new SellingItem();
      this.process.device_items().push(si);
    }

    var sip = new SellingItemRepresentation(si, dom_object, this);
    si.set('process', this.process);
    this.device_item_representations.push(sip);
    if (sip.dom_object.down('.count input').value <= 0)
      sip.dom_object.down('.count input').value = 1;
    sip.count_changed(null);
  },

  register_service_item: function(dom_object) {
    var opt_si_id = dom_object.down('td.product_id input[type=hidden]', 1);
    if (opt_si_id && opt_si_id.value) {
      var si = this.process.service_item(opt_si_id.value);
    } else {
      var si = new ServiceItem();
      this.process.service_items().push(si);
    }

    var sip = new ServiceItemRepresentation(si, dom_object, this);
    si.set('process', this.process);
    this.service_item_representations.push(sip);
    if (sip.dom_object.down('.count input').value <= 0)
      sip.dom_object.down('.count input').value = 1;
    sip.count_changed(null);
  },

  remove_item: function(item) {
    if (item.dom_object.hasClassName('service')) {
      this.servic_item_representations = this.service_item_representations.without(item);
      item.service_item.set('count', 0);
    } else {
      this.device_item_representations = this.device_item_representations.without(item);
      item.selling_item.set('count', 0);
    }
    this.table_changed();
  }

});
