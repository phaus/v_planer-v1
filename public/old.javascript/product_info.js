var ProductInfo = Class.create({
  initialize: function(product) {
    this.product     = product;
    this.dom_object  = new Element('div', {class: 'product_info'}).hide();
    this.hide_button = new Element('input', {type: 'image', title: 'Produtdetails ausblenden', src: relative_url_root + 'images/icons_16/close.png', class: 'toolchain'});
    this.edit_button = new Element('input', {type: 'image', title: 'Produktdaten bearbeiten',  src: relative_url_root + 'images/icons_16/edit.png',  class: 'toolchain'});
    this.dom_object.insert(this.hide_button);
    this.dom_object.insert(this.edit_button);
    this.dom_object.insert(new Element('div'));
    this.register_event_handlers();
    $('product_infos').insert({after: this.dom_object});
    this.dom_object.absolutize();
    this.dom_object.clonePosition($('main_content'));
  },

  show: function() {
    new Ajax.Updater(this.dom_object.down('div'), this.product.url(), {method: 'get'});
    new Effect.Appear(this.dom_object);
  },

  hide: function(event) {
    event.stop();
    new Effect.Fade(this.dom_object);
  },

  save: function(event) {
    event.stop();
    var form = event.element();
    form.request();
    form.stopObserving('submit', this.event_handlers.save);
    this.show();
  },

  edit: function(event) {
    event.stop();
    var self = this;
    new Ajax.Request(this.product.url() + '/edit', {
      method: 'get',
      onSuccess: function(response) {
        var div = self.dom_object.down('div');
        div.update(response.responseText);
        div.down('form').observe('submit', self.event_handlers.save);
        show_or_hide_fieldsets();
      }
    });
  },

  remove: function() {
    this.unregister_event_handlers();
    this.dom_object.remove();
  },

  event_handlers: {},

  register_event_handlers: function() {
    this.event_handlers.hide = this.hide.bindAsEventListener(this);
    this.event_handlers.edit = this.edit.bindAsEventListener(this);
    this.event_handlers.save = this.save.bindAsEventListener(this);

    this.hide_button.observe('click', this.event_handlers.hide);
    this.edit_button.observe('click', this.event_handlers.edit);
  },

  unregister_event_handlers: function() {
    this.hide_button.stopObserving('click', this.event_handlers.hide);
    this.edit_button.stopObserving('click', this.event_handlers.edit);
  }
});
