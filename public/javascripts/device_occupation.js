var DeviceOccupation = ActiveResource.inherit({
  belongs_to: {
    'device': {
      class_name: 'Device',
    }
  },

  resource: 'device_occupations',
});


var DeviceOccupationRepresentation = Class.create(PlanningObject, {

  initialize: function($super, obj, dimensions) {
    $super(obj, dimensions);
//     this.selectionMouseOutHandler = this.readInput.bindAsEventListener(this);
    this.shiftStartEventHandler  = this.startShift.bindAsEventListener(this);
    this.shiftEventHandler       = this.doShift.bindAsEventListener(this);
    this.shiftEndEventHandler    = this.endShift.bindAsEventListener(this);

    this.resizeStartEventHandler = this.startResize.bindAsEventListener(this);
    this.resizeEventHandler      = this.doResize.bindAsEventListener(this);
    this.resizeEndEventHandler   = this.endResize.bindAsEventListener(this);
  },

  initDomElements: function($super) {
    $super(['ENselection', 'ENfinal']);

    this.leftarrow = new Element('div');
    this.leftarrow.addClassName('ENarrow');
    this.leftarrow.addClassName('ENleftarrow');
    this.domObject.appendChild(this.leftarrow);

    this.rightarrow = new Element('div');
    this.rightarrow.addClassName('ENarrow');
    this.rightarrow.addClassName('ENrightarrow');
    this.domObject.appendChild(this.rightarrow);

    this.handleDiv = new Element('div');
    this.handleDiv.addClassName('ENhandle');
    this.domObject.appendChild(this.handleDiv);

    this.domObject.observe('mousedown', this.shiftStartEventHandler);
    this.handleDiv.observe('mousedown', this.resizeStartEventHandler);
  },

  updateInfo: function() {
//     Event.stopObserving(this.infoDiv, 'mouseout', this.selectionMouseOutHandler);
    this.infoDiv.innerHTML = "&nbsp;&nbsp;(<em>Doppelklick zum bearbeiten</em>)<br />" +
                             "<table><tr><th>Notitzen:</th><td>" + this.theObject.get('comments') + "</td></tr>" +
                             "<tr><th>Beginn:</th><td class=\"date\">" + german_datetime(this.theObject.get('from_date')) + "</td></tr>" +
                             "<tr><th>Ende:</th><td class=\"date\">"   + german_datetime(this.theObject.get('to_date')) + "</td></tr></table>";
//     Event.observe(this.infoDiv, 'mouseout', this.selectionMouseOutHandler);
  },

  create: function($super, container) {
    $super(container);
    this.domObject.observe('mousedown', this.shiftStartEventHandler);
    this.handleDiv.observe('mousedown', this.resizeStartEventHandler);
    document.observe('mousemove', this.resizeEventHandler);
    document.observe('mouseup',   this.resizeEndEventHandler);
  },

  startResize: function(event) {
    if (Event.element(event)!= this.handleDiv) return false;
    Event.stop(event);
    this.startPos = this.container.eventPosition(event)[0];
    document.observe('mousemove', this.resizeEventHandler);
    document.observe('mouseup',   this.resizeEndEventHandler);
    this.domObject.removeClassName('ENfinal');
    this.domObject.addClassName('ENresizing');
    this.infoDiv.hide();
  },

  doResize: function(event) {
    Event.stop(event);
    var evtOffs   = this.container.eventPosition(event);
    var objectPos = this.domObject.positionedOffset()[0];
    var new_width = evtOffs - objectPos;
    if (new_width < 0)
      new_width = 0;
//     else if (newpos > this.dimensions.plannerWidth)
//       newpos = this.dimensions.plannerWidth - this.domObject.getWidth();
    else if (this.collidesWithOtherElement(objectPos, new_width))
      return false;
//     this.theSelection.firstDescendant().innerHTML = wdth + ' Tage';
    this.domObject.style.width = new_width + 'px';
  },

  endResize: function(event) {
    Event.stop(event);
    this.domObject.addClassName('ENfinal');
    this.domObject.removeClassName('ENresizing');
    document.stopObserving('mousemove', this.resizeEventHandler);
    document.stopObserving('mouseup',   this.resizeEndEventHandler);
    var elmOffs = Position.positionedOffset(this.domObject);
//     this.theObject.set('from_date', this.container.container.date(elmOffs[0]));
    this.theObject.set('to_date', this.container.container.date(elmOffs[0] + this.domObject.getWidth()));
    this.pushPosition();
    this.updateInfo();
    this.infoDiv.show();
  },

  startShift: function(event) {
    var theElement = Event.element(event);
    if (theElement == this.domObject) {
      Event.stop(event);
      this.startPos = this.container.eventPosition(event);
      var elmOffs   = this.domObject.positionedOffset();
      this.delta    = this.startPos - elmOffs[0];
      this.domObject.removeClassName('ENfinal');
      this.domObject.addClassName('ENshifting');
      document.observe('mouseup',   this.shiftEndEventHandler);
      document.observe('mousemove', this.shiftEventHandler);
      this.shift_happened = false;
    }
  },

  doShift: function(event) {
    if (!this.shift_happened) {
      this.okDiv.hide();
      this.undoDiv.hide();
      this.closeDiv.hide();
      this.infoDiv.hide();
      this.shift_happened = true;
    }
    var theElement = Event.element(event);
    Event.stop(event);
    var evtOffs = this.container.eventPosition(event);
    var newpos  = evtOffs - this.delta;
//     if (newpos < 0)
//       newpos = 0;
//     if (newpos + this.domObject.getWidth() > this.dimensions.plannerWidth)
//       newpos = totalwidth - this.domObject.getWidth();
    if (this.collidesWithOtherElement(newpos, this.domObject.getWidth()))
      return false;
    this.domObject.style.left = newpos + 'px';
  },

  endShift: function(event) {
    var theElement = Event.element(event);
    Event.stop(event);
    this.domObject.removeClassName('ENshifting');
    this.domObject.addClassName('ENfinal');
    Event.stopObserving(document, 'mousemove', this.shiftEventHandler);
    Event.stopObserving(document, 'mouseup',   this.shiftEndEventHandler);
    if (this.shift_happened) {
      var elmOffs = Position.positionedOffset(this.domObject);
      this.theObject.set('from_date', this.container.container.date(elmOffs[0]));
      this.theObject.set('to_date',   this.container.container.date(elmOffs[0] + this.domObject.getWidth()));
      this.pushPosition();
      this.updateInfo();
      this.okDiv.show();
      this.undoDiv.show();
      this.closeDiv.show();
      this.infoDiv.show();
      this.shift_happened = false;
    }
  },

  collidesWithOtherElement: function(objStart, objWidth) {
    return this.domObject.siblings().any(function(sibling) {
      var siblingStart = sibling.positionedOffset()[0];
      var siblingEnd   = siblingStart + sibling.getWidth();
      return (objStart + objWidth > siblingStart && objStart < siblingEnd);
    });
  },

  objectEditor: function() {
    var edit_from_date = new Element('input',    { id: 'edit_from_date', size: 30, type: 'text', value: german_datetime(this.theObject.get('from_date')) });
    var edit_to_date   = new Element('input',    { id: 'edit_to_date',   size: 30, type: 'text', value: german_datetime(this.theObject.get('to_date')) });
    var edit_comments  = new Element('textarea', { id: 'edit_comments',  cols: 30, rows: 6, innerHTML: this.theObject.get('comments') });
    var theForm = new Element('form', { action: '#', method: 'post'});
    with (theForm) {
      appendChild(label('von'));
      appendChild(edit_from_date);
      appendChild(document.createElement('br'));
      appendChild(label('bis'));
      appendChild(edit_to_date);
      appendChild(document.createElement('br'));
      appendChild(edit_comments);
      appendChild(document.createElement('br'));
    }
    edit_from_date.observe('change', this.positionEditedHandler);
    edit_to_date.observe('change', this.positionEditedHandler);
    return theForm;
  },

  save: function($super, event) {
    Event.stop(event);
    if (this.editor_active) {
      this.theObject.set('from_date', convert_german_datetime($F('edit_from_date')));
      this.theObject.set('to_date',   convert_german_datetime($F('edit_to_date')));
      this.theObject.set('comments',  $F('edit_comments'));
    }
    $super();
  }
});
