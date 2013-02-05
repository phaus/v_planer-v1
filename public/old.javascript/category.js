var Category = ActiveResource.inherit({
  has_many: {
    'devices': {}
  },
  resource: 'categories'
});

var DeviceIcon = Class.create({
  initialize: function(device, category) {
    this.theObject   = device;
    this.theCategory = category;
    this.domObject   = new Element('div', {class: 'device icon'});
    this.removeFromCategoryEventHandler = this.removeFromCategory.bindAsEventListener(this);
    this.draw();
  },

  draw: function() {
    var icon_image = new Element('img', {src: '/images/icons_32/device.png'});
    var icon_text  = new Element('div', {class: 'name'});
    icon_text.innerHTML = this.theObject.get('name');
    this.domObject.insert(icon_image);
    this.domObject.insert(icon_text);
    new Draggable(this.domObject, {
      revert:   true,
      ghosting: true
    });

    if (this.theCategory) {
      var closer_link = new Element('a',   {href: '#', class: 'closer'});
      var closer_img  = new Element('img', {src: '/images/icons_16/no.png'});
      closer_link.insert(closer_img);
      this.domObject.insert(closer_link);
      Event.observe(closer_link, 'click', this.removeFromCategoryEventHandler);
    }
  },

  removeFromCategory: function(event) {
    event.stop();
    this.theCategory.removeDevice(this);
  },

  toElement: function() {
    return this.domObject;
  }
});

var CategoryRepresentation = Class.create({
  initialize: function(category_div) {
    this.domObject  = category_div;
    this.theObject  = Category.findOne(this.getId(category_div));
    this.addDeviceEventHandler    = this.addDevice.bindAsEventListener(this);
    this.removeDeviceEventHandler = this.removeDevice.bindAsEventListener(this);
    this.loadDevices();
    this.draw();
  },

  loadDevices: function() {
    this.deviceIcons = $H();
    var self = this;

    this.theObject.devices().each(function(device) {
      var icon = new DeviceIcon(device, self);
      self.deviceIcons.set(device.id, icon);
    });
  },

  draw: function() {
    var s = this;
      bvthis.deviceIcons.values().each(function(icon) {
      s.domObject.down('ul.devices').insert(icon);
    });
    Droppables.add(this.domObject, {
      accept:     'device',
      hoverclass: 'hover',
      onDrop:     this.addDeviceEventHandler
    });
  },

  addDevice: function(element) {
    var current_category = element.up('div.category');
    if (current_category == this.domObject) return;
    var device_icon = this.iconObjectFor(element);
//     var icon = this.deviceIcons.get(element.domObject.name);
//     new Ajax.Request(icon.theObject.), {
//       method:     'post',
//       parameters: {id: device_id},
//       onSuccess:  callback()
//     });
  },

  removeDevice: function(device_icon) {
    var icon = this.deviceIcons.unset(device_icon.theObject.id);
    if (this.theObject.device(icon.theObject.id).destroy());
    icon.domObject.remove();
  },

  getId: function(element) {
    return element.id.split('_').last();
  },

  iconObjectFor: function(element) {
    alert(this.deviceIcons.values());
    var device = this.deviceIcons.values().find(function(icon) {
      return true;
    });
    alert(device);
  },

  toElement: function() {
    return this.domObject;
  }

});
