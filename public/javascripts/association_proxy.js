/*
  This class is used to represent an association between two classes.
  For example, if Blog has_many Posts, a call to blog.posts() would
  not directly yield an array of posts, but in fact an instance of
  HasManyrelationship, which is a child of AssociationProxy. This
  Object acts as an Array, but also provides more methods like
  blog.entries().saveAll() and so on.
*/

var AssociationProxy = Class.create({
  // owner: the CLASS this proxy belongs to, e.g. blog (has_many posts)
  // target: the CLASS this proxy points at, e.g. posts
  initialize: function(owner, target) {
    this.owner  = owner;
    this.target = target;
  },

  build: function(attributes) {

  },

  destroy: function(element) {

  },

  saveOne: function(id) {

  },

  saveAll: function() {

  },

  element_url: function(id) {

  },

  resource_url: function(id) {
    return this.owner.element_url();
  }
});

var HasOneRelationship = Class.create(AssociationProxy, {
  initialize: function($super, options) {
    $super();
    this.target_object = null;
    // "ghost" object to provide the interface for the associoated object
    var ghost = eval("new " + this.target.className);
    var methods = Object.keys(ghost);
    for (var i=0, l=methods.length; i<l; ++i) {
      if (Object.isMethod(methods[i])) {
        var method_name = methods[i];
        var method_args = eval("this.target."+method_name+".argumentNames()");
        eval(
          "this."+method_name+" = function("+method_args.join(',')+") {"+
            "if (this.target_object == null) this.loadTargetObject();" +
            // TODO: handle record not found error
            "return this.target_object."+method_name+"("+method_args.join(',')+");" +
          "}"
        )
      }
    }
  },

  loadTargetObject: function() {
    var existing_element = ActiveResource.objectCache.get(this.target.className).get(this.target_id.toString());
    if (existing_element) return existing_element;
    var resp = this.target.findByUrl(this.owner.element_url() + '.json');
    debug('RESPONSE to "+klass.className+"#"+relation.name+"_url(): ' + resp);
    return resp;
  }


});
