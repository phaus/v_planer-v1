function sp2i(arg) {
  if (parseInt(arg) < 10)
    return '0' + arg;
  else
    return '' + arg;
}

function german_date(date) {
  var d = new Date(date);
  return sp2i(d.getDate()) + "." + sp2i(d.getMonth()) + "." + d.getFullYear();
}

function german_datetime(date) {
  var d = new Date(date);
  return sp2i(d.getDate()) + "." + sp2i(d.getMonth()+1) + "." + d.getFullYear() + " " + sp2i(d.getHours()) + ":" + sp2i(d.getMinutes());
}

function parse_german_datetime(date) {
  var d = date.match(/(\d{2})\.(\d{2})\.(\d{4}),{0,1}\s+(\d{2}):(\d{2})/);
  if (d) return new Date(parseInt(d[3]),parseInt(d[2])-1,parseInt(d[1]),parseInt(d[4]),parseInt(d[5]));
  else return false;
}

function convert_german_datetime(date) {
  var d = date.match(/(\d{2})\.(\d{2})\.(\d{4}),{0,1}\s+(\d{2}):(\d{2})/);
  if (d) {
    return ''+d[3]+'/'+d[2]+'/'+d[1]+' '+d[4]+':'+d[5]+':00';
} else
    return '';
}

var PlanningObject = Class.create({
  initialize: function(theObject, dimensions) {
    this.hist       = new Array(),
    this.histPos    = -1;
    this.id         = "po_" + theObject.id;
    this.theObject  = theObject;
    this.dimensions = dimensions;
    this.closeEventHandler        = this.closeSelf.bindAsEventListener(this);
    this.undoEventHandler         = this.undoPosition.bindAsEventListener(this);
    this.saveEventHandler         = this.save.bindAsEventListener(this);
    this.editEventHandler         = this.edit.bindAsEventListener(this);
    this.closeEditEventHandler    = this.closeEdit.bindAsEventListener(this);
    this.saveResponseEventHandler = this.onSaveResponse.bindAsEventListener(this);
    this.positionEditedHandler    = this.positionEdited.bindAsEventListener(this);
  },

  // Return length [days] of unavailability period:
  occupationLength: function() {
    return (this.to_date() - this.from_date()) / 86400000;
  },

  pushPosition: function() {
    if (this.histPos==-1) {
      this.undoDiv.hide();
    } else if (this.histPos == 0) {
      this.undoDiv.show();
      this.okDiv.className = 'ENnyok';
      this.okDiv.observe('click', this.saveEventHandler);
    }
    this.hist[++this.histPos] = [this.container, '' + this.theObject.get('from_date'), '' + this.theObject.get('to_date')];
  },

  popPosition: function() {
    if (this.histPos > 0)
      this.histPos--;
    var d = this.hist[this.histPos];
    this.container = d[0];
    this.theObject.set('from_date', d[1]);
    this.theObject.set('to_date',   d[2]);
    if (this.histPos == 0) {
      this.undoDiv.hide();
      this.okDiv.className = 'ENok';
      this.okDiv.stopObserving('click', this.saveEventHandler);
    }
  },

  clearHistory: function() {
    this.histPos = 0;
    this.hist    = [];
    this.undoDiv.hide();
    this.okDiv.className = 'ENok';
    this.okDiv.stopObserving('click', this.saveEventHandler);
  },

  closeSelf: function(event) {
    if (Event.element(event)!= this.closeDiv) return false;
    Event.stop(event);
    if (!confirm('Wirklich löschen?')) return false;
    if (this.theObject.new_record || this.theObject.destroy()) {
      this.undoDiv.stopObserving('click', this.undoEventHandler);
      this.okDiv.stopObserving('click', this.saveEventHandler);
      this.domObject.remove();
    } else {
      alert('Fehler beim Löschen.');
    }
  },

  undoPosition: function(event) {
    if (Event.element(event)!= this.undoDiv) return false;
    Event.stop(event);
    this.popPosition();
    this.redraw();
  },

  redraw: function() {
    var startpos = this.container.position(Date.parse(this.theObject.get('from_date')));
    if (!startpos) return false;
    with (this.domObject.style) {
      left  = (startpos * this.dimensions.pxPerDay) + 'px';
      width = this.occupationLength() * this.dimensions.pxPerDay + 'px';
    }
    this.container.domObject.appendChild(this.domObject);
    this.updateInfo();
  },

  draw: function(container, dont_push) {
    this.initDomElements();
    this.container = container;
    var startpos   = container.position(Date.parse(this.theObject.get('from_date')));
    if (!startpos) return false;
    with (this.domObject.style) {
      left   = (startpos * this.dimensions.pxPerDay) + 'px';
      width  = this.occupationLength() * this.dimensions.pxPerDay + 'px';
    }
    this.updateInfo();
    this.container.domObject.appendChild(this.domObject);
    if (!dont_push) this.pushPosition();
    return true;
  },

  initDomElements: function(class_names) {
    if (!Object.isUndefined(this.domObject)) return false;

    this.infoDiv = new Element('div');
    with (this.infoDiv) {
      addClassName('ENinformer');
      style.top    = (this.dimensions.pxPerDevice + 2) + 'px';
      style.zIndex = 10000;
    }

    this.okDiv = new Element('div');
    this.okDiv.addClassName('ENok');

    this.undoDiv = new Element('div');
    this.undoDiv.addClassName('ENreloader');
    this.undoDiv.observe('click', this.undoEventHandler);

    this.closeDiv = new Element('div');
    this.closeDiv.addClassName('ENcloser');
    this.closeDiv.observe('click', this.closeEventHandler);

    this.domObject = new Element('div');
    class_names.push('ENPO');
    with (this.domObject) {
      for(var i=0; i<class_names.length; i++) {
        addClassName(class_names[i]);
      }
      id = this.id;
      appendChild(new Element('div'));
      style.height = (this.dimensions.pxPerDevice - 2) + 'px';
      appendChild(this.okDiv);
      appendChild(this.undoDiv);
      appendChild(this.closeDiv);
      appendChild(this.infoDiv);
      observe('dblclick', this.editEventHandler);
    }
  },

  from_date: function() {
    return new Date(this.theObject.get('from_date'));
  },

  to_date: function() {
    return new Date(this.theObject.get('to_date'));
  },

  edit: function(event) {
    if (Event.element(event) != this.domObject) return false;
    Event.stop(event);
    this.infoDiv.hide();
    this.domObject.stopObserving('dblclick', this.editEventHandler);

    this.lockDevices();

    this.cancelButton = new Element('input');
    with (this.cancelButton) {
      value = 'Abbrechen';
      type  = 'reset';
    }

    this.saveButton = new Element('input', { value: 'Speichern', type: "submit" });

    this.theEditor = this.objectEditor();
    with (this.theEditor) {
      appendChild(this.cancelButton);
      appendChild(this.saveButton);
      observe('reset',  this.closeEditEventHandler);
      observe('submit', this.saveEventHandler);
    }

    this.editCloseDiv = new Element('div');
    with (this.editCloseDiv) {
      addClassName('ENcloseEdit');
      style.right = '1px';
      observe('click', this.closeEditEventHandler);
    }

    this.editDiv = new Element('div', {display: 'none'});
    with (this.editDiv) {
      addClassName('ENeditor');
      style.top = this.dimensions.pxPerDevice + 1 + 'px';
      appendChild(this.editCloseDiv);
      appendChild(this.theEditor);
    }

    this.domObject.appendChild(this.editDiv);
    this.domObject.addClassName('ENactive');

    var pos       = this.editDiv.cumulativeOffset();
    var topObject = this.domObject.up('div').up('div').up('div');
    topObject.appendChild(this.editDiv);
    var x_offset = pos[0]  - this.editDiv.up('div').scrollLeft;
    var y_offset = pos[1] - document.documentElement.scrollTop;
    if (x_offset < 0)
      x_offset = 0;
    else if (x_offset > window.innerWidth - 400)
      x_offset = window.innerWidth - 400
    if (y_offset < 215)
      y_offset = 215;
    else if (y_offset > window.innerHeight - 200)
      y_offset = window.innerHeight - 200;
    this.editDiv.style.left = '' + x_offset + 'px';
    this.editDiv.style.top  = '' + y_offset + 'px';
    new Effect.Grow(this.editDiv, {duration: .5});
    this.editor_active = true;
  },

  closeEdit: function(event) {
    if (event) Event.stop(event);

    this.editCloseDiv.stopObserving('click', this.closeEditEventHandler);
    this.theEditor.stopObserving('reset',    this.closeEditEventHandler);
    this.theEditor.stopObserving('submit',   this.saveEventHandler);

    this.unlockDevices();
//     new Effect.Shrink(this.editDiv, {
//       duration: .5,
//       afterFinish: function(effectObject) {
        this.editDiv.remove();
//       }
//     });
    this.editDiv = null;
    this.infoDiv.show();
    this.domObject.removeClassName('ENactive');
    this.domObject.observe('dblclick', this.editEventHandler);
    this.editor_active = false;
  },

  save: function(event) {
    this.theObject.save(this.saveResponseEventHandler);
    return false;
  },

  onSaveResponse: function(success) {
    if (success) {
      this.clearHistory();
      this.closeEdit();
    } else {
      new Effect.Highlight(this.editDiv, {restorecolor: '#ff0000', endcolor: '#ff0000', duration: 1});
      this.editDiv.style.border = '2px dotted #ffff00';
    }
    this.updateInfo();
  },

  create: function(container) {
    this.draw(container);
    new Effect.Highlight(this.domObject, {endcolor: '#F69194', duration: .3});
  },

  lockDevices: function() {
    if (Object.isUndefined(this.blockingDiv) || this.blockingDiv==null) {
      this.blockingDiv = new Element('div');
      this.container.container.domObject.appendChild(this.blockingDiv);
      this.domObject.style.zIndex = 500;
      with (this.blockingDiv) {
        style.position = 'absolute';
        style.display  = 'block';
        style.backgroundColor = 'transparent';
        style.zIndex   = 480;
        clonePosition(this.container.container.domObject);
      }
    }
  },

  unlockDevices: function() {
    if (Object.isUndefined(this.blockingDiv) || this.blockingDiv==null) return false;
    this.domObject.style.zIndex = 50;
    this.blockingDiv.remove();
    this.blockingDiv = null;
  },

  positionEdited: function(event) {
    var element = Event.element(event);
    var value   = $F(element);
    var name    = element.id.substr('edit_'.length);
    var d = parse_german_datetime(value);
    if (d) {
      this.theObject.set(name, ''+d);
      this.redraw();
    } else {
      alert("Das eingegebene Datum entspricht nicht dem Format 'TT.MM.JJJJ hh:mm'!");
    }
  }
});

