var Device = ActiveResource.inherit({
  has_many: {
    'rental_periods': {},
  },
  resource: 'devices',

  isAvailable: function(from_date, to_date) {
    if (typeof(from_date) != 'object')
      from_date = new Date(from_date);
    if (typeof(to_date) != 'object')
      to_date = new Date(to_date);

    var unavailabilities = this.rental_periods()
    for (var i=0, len=unavailabilities.length; i<len; i++) {
      unav = unavailabilities[i];
      if (unav.from_date < to_date && unav.to_date > from_date) return false;
    }
    return true;
  }
});

// var DeviceRepresentation = Class.create({
//   initialize: function(device, index, from_date, to_date, dimensions) {
//     this.theObject  = device;
//     this.from_date  = from_date;
//     this.to_date    = to_date;
//     this.dimensions = dimensions;
//     this.index      = index;
//     this.startSelectEventHandler = this.startSelect.bindAsEventListener(this);
//   },
//
//   initDomElements: function() {
//     this.domObject = document.createElement('div');
//     this.labelDiv  = document.createElement('div');
//     var start_day_of_week = this.from_date.getDay();
//     with (this.labelDiv) {
//       appendChild(label('<a href="'+this.theObject.url()+'/edit">' + this.theObject.get('name') + '</a>'));
//       addClassName('deviceLabel');
//       style.width  = this.dimensions.deviceLabelWidth + 'px';
//       style.height = this.dimensions.pxPerDevice + 'px';
//       style.top    = (this.dimensions.headerHeight + this.index * (1 + this.dimensions.pxPerDevice)) + 'px';
//       style.zIndex = 50;
//     }
//
//     with (this.domObject) {
//       id = 'device_' + this.theObject.id;
//       addClassName('deviceAvailability');
// //       title = this.theObject.get('name');
//       setStyle({
//         width:  this.dimensions.plannerWidth + 'px',
//         height: this.dimensions.pxPerDevice + 'px',
//         top:    this.dimensions.headerHeight + ind * (1 + this.dimensions.pxPerDevice) + 'px',
//         left:   this.dimensions.deviceLabelWidth + 2 + 'px',
//         backgroundPosition: '-' + (start_day_of_week - 1) * this.dimensions.pxPerDay - 1 + 'px -1px'
//       });
//     }
//
// //     var acquireElementHandler = this.acquireElement.bind(this);
// //     Droppables.add(this.domObject, {
// //       accept: ['ENoccupied'],
// //       hoverclass: 'droppable_hover',
// //       onDrop: acquireElementHandler
// //     });
//   },
//
// //   acquireElement: function(draggable, droppable, event) {
// //     var drg = draggable.remove();
// //     drg.style.top = '0px';
// //     droppable.appendChild(drg);
// //     var device_id = drg.id.substr('device_'.length);
// //     if (drg.hasClassName('device_occupation')) {
// //       var element_id = drg.id.substr('device_occupation_'.length);
// //       var element = DeviceOccupation.findOne(element_id);
// //     } else if (drg.hasClassName('rental_period')) {
// //       var element_id = drg.id.substr('rental_period_'.length);
// //       var element = RentalPeriod.findOne(element_id);
// //     }
// //     element.set('device_id', device_id);
// // //     element.;
// //   },
//
//   draw: function(container) {
//     this.initDomElements();
//     this.container = container;
//     this.siblings  = container.devices;
//     this.container.domObject.appendChild(this.labelDiv);
//     this.container.domObject.appendChild(this.domObject);
//
//     var rental_periods = this.theObject.rental_periods();
//     for (var i=0, l=rental_periods.length; i<l; i++) {
//       var rpr = new RentalPeriodRepresentation(rental_periods[i], this.dimensions);
//       rpr.draw(this);
//     }
//     var occupations = this.theObject.occupations();
//     if (occupations) {
//       for (var i=0, l=occupations.length; i<l; i++) {
//         var tor = new DeviceOccupationRepresentation(occupations[i], this.dimensions);
//         tor.draw(this);
//       }
//     }
//     Event.observe(this.domObject, 'mousedown', this.startSelectEventHandler);
//   },
//
//   position: function(date) {
// //     if (date < this.from_date || date > this.to_date)
// //       return false;
// //     else
//     return (date - this.from_date) / 86400000;
//   },
//
//   startSelect: function(event) {
//     if (Event.element(event)!= this.domObject) return false;
//     Event.stop(event);
//     var startPos = this.eventPosition(event);
//     var from = this.container.date(startPos);
//     var to   = this.container.date(startPos + this.dimensions.pxPerDay); // start with 1 day duration
//     var po   = new DeviceOccupationRepresentation(
//       new DeviceOccupation({
//         'from_date':  from,
//         'to_date':    to,
//         'device_id': this.theObject.id,
//         'id':         0,
//         'comments':   ''
//       }
//     ), this.dimensions);
// //     this.makeActive(po.domObject);
//     po.create(this);
//   },
//
//   eventPosition: function(event) {
//     var elemoffs = this.domObject.cumulativeOffset();
//     var scroffs  = this.domObject.cumulativeScrollOffset();
//     return Event.pointerX(event) - elemoffs[0] + scroffs[0];
//   }
// });
