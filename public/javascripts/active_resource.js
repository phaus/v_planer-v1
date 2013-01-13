// ------------------------------------------------------------------- //
//  COPYRIGHT by Willem van Kerkhof <wvk@consolving.de>                //
//  Released under the Terms of the GNU General Public License v. 2.0  //
// ------------------------------------------------------------------- //

var relative_url_root = '/v_planer/'
// var relative_url_root = '/'

// ------------------------------------------------------------------- //
//                   NO CHANGES BELOW THIS LINE!                       //
// ------------------------------------------------------------------- //

String.prototype.singularize = function() {
//   if (['sheep', 'fish'].include(this)) return this
  if (this.endsWith('ses')) return this.substr(0, this.length - 2);
  else if (this.endsWith('ies')) return this.substr(0, this.length - 3) + 'y';
  else if (this.endsWith('s')) return this.substr(0, this.length - 1);
  else if (this.endsWith('ae')) return this.substr(0, this.length - 2);
  else return this;
};

String.prototype.pluralize = function() {
//   if (['sheep', 'fish'].include(this)) return this
  if (this.endsWith('ses')) return this;
  else if (this.endsWith('s')) return this + 'es';
  else if (this.endsWith('ae')) return this;
  else if (this.endsWith('a')) return this + 'e';
  else if (this.endsWith('y')) return this + 'ies';
  else return this + 's';
};

String.prototype.toClassName = function() {
  return this.singularize().capitalize().dasherize().camelize();
}

function debug(content) {
//   alert(content);
//   $('debug_div').innerHTML += content + "<hr />";
  console.log(content);
}

var ActiveResource = Class.create({
  initialize: function(options) {
    debug(this.className + '#initialize(' + $H(options).values() + ')');
    this.attributes = $H();
    this.attributes.update($H(options));
    this.id = options ? options.id : null;
    this.new_record = !this.id;
//     this.initializeAssociations();
    if (Object.isFunction(this.afterInitialize)) {
      this.afterInitialize(options);
    }
  },

  get: function(attribute) {
    return this.attributes.get(attribute);
  },

  set: function(attribute, value) {
    return this.attributes.set(attribute, value);
  },

  url: function() {
    if (this.my_url)
      return this.my_url;
    else if (this.id == null)
      return this.class().resource_url();
    else
      return this.class().resource_url() + '/' + this.id;
  },

  class: function() {
    return eval(this.className);
  },

  save: function(callback) {
    debug(this.className + '#save() to ' + this.url());
    this.Class.cachedRequests[this.url()] = null;
    new Ajax.Request(this.url(),
      { asynchronous:   true,
        method:         (this.id==null ? 'post' : 'put'),
        parameters:     this.postParams(),
        requestHeaders: {Accept: 'application/json'},
        onComplete: function (response) {
          if (response.status < 300) {
            this.new_record = false;
            callback(true);
          } else {
            debug(response.responseText);
            callback(false);
          }
        }
      }
    );
  },

  destroy: function() {
    var status = true;
    debug(this.className + '#destroy() to ' + this.url());
    this.Class.cachedRequests[this.url()] = null;
    new Ajax.Request(this.url(),
      { asynchronous:   false,
        method:         'delete',
        parameters:     this.postParams(),
        requestHeaders: {Accept: 'application/json'},
        onComplete: function (response) {
          if (response.status > 300) {
            debug(response.responseText);
            status = false;
          }
        }
      }
    );
    return status;
  },

  postParams: function() {
    var params     = $H();
    var className  = this.resource.singularize();
    var attributes = this.attributes;
    attributes.keys().each(function(key) {
      params.set(className + '[' + key + ']', attributes.get(key));
    });
    return params;
  },

  initializeAssociations: function() {
//     this.associations = $H();
//     for (i=0 l=this.associations.length; ++i) {
//       var association_proxy = this.associations[i];
//       eval("this."+association_proxy.+");
//     }
  }
});

ActiveResource.objectCache = $H();

ActiveResource.Class = {
  resource_url: function() {
    return  relative_url_root + this.resource;
  },

  element_url: function(id) {
     return this.resource_url() + '/' + id;
  },

  findOne: function(id, callback) {
    debug(this.className + '.findOne('+id+', '+callback+')');
    if (!id) return;
    var existing_element = ActiveResource.objectCache.get(this.className).get(id.toString());
    if (existing_element) {
      if (Object.isFunction(callback)) {
        callback(existing_element);
      } else {
        return existing_element;
      }
    } else {
      return this.findByUrl(this.element_url(id) + '.json', callback)
    }
  },

  findAll: function(callback) {
    debug(this.className + '.findAll('+callback+')');
    return this.findByUrl(this.resource_url(), callback)
  },

  findByUrl: function(url, callback) {
    debug(this.className + '.findByUrl('+url+', '+callback+')');
    if (Object.isFunction(callback)) {
      this.fetchAsynchronously(url, function(result) {
        callback(this.prepareFetchedResult(result));
      });
    } else {
      var result = this.fetchSynchronously(url);
      if (result)
        return this.prepareFetchedResult(result);
      else
        return null;
    }
  },

  prepareFetchedResult: function(result) {
    debug(this.className + '.prepareFetchedResult('+result+')');
    if (Object.isArray(result)){
      return this.arrayOfInstances(result);
    } else {
      return this.newInstance(result);
    }
  },

  getCache: function(class_name) {
    debug(this.className + '.getCache('+class_name+')');
    if (class_name) return ActiveResource.objectCache.get(this.className).get(class_name);
    else return ActiveResource.objectCache.get(this.className);
  },

  newInstance: function(data) {
    debug(this.className + ".newInstance("+$H(data).values()+")");
    var new_instance = eval("new "+this.className+"(data)");
//     eval("ActiveResource.objectCache.get('"+this.className+"').set('"+data.id+"', new "+this.className+"(data))");
    ActiveResource.objectCache.get(this.className).set(new_instance.id.toString(), new_instance);
    return new_instance;
  },

  arrayOfInstances: function(data) {
    debug(this.className + ".arrayOfInstances("+$A(data)+")");
    var instances = [];
    for (i=0, l=data.length; i<l; ++i) {
      var new_instance = this.newInstance(data[i]);
//       alert(new_instance.get('name'));
      instances[i] = new_instance;
    }
    return instances;
  },

  cachedRequests: {},

  fetchSynchronously: function(url) {
    debug(this.className + ".fetchSynchronously("+url+")");
    if (this.cachedRequests[url]) return this.cachedRequests[url];
    var result;
    new Ajax.Request(url,
      { asynchronous: false,
        method: 'get',
        requestHeaders: {Accept: 'application/json'},
        onComplete: function(response) {
          if (response.status == 200)
            result = response.responseJSON;
          else
            result = null;
//           debug('<strong>' + response.statusText + '</strong>: ' + response.responseText);
        }
      }
    );
    this.cachedRequests[url] = result;
    return result;
  },

  fetchAsynchronously: function(url, callback) {
    debug(this.className + '.fetchAsynchronously(' + url + ', ' + callback + ')');
    if (this.cachedRequests[url]) {
      callback(this.cachedRequests[url]);
    } else {
    var self = this;
      new Ajax.Request(url,
        { asynchronous: true,
          method: 'get',
          requestHeaders: {Accept: 'application/json'},
          onComplete: function (response) {
  //           debug('<strong>' + response.statusText + '</strong>: ' + response.responseText);
            if (response.status == 200)
              self.cachedRequests[url] = response.responseJSON;
            else
              self.cachedRequests[url] = null;
            callback(self.cachedRequests[url]);
          }
        }
      );
    }
  }
}

ActiveResource.inherit = function(parent_or_class, sub_class_code) {
  // this  => ActiveResource
  // klass => MyClass

  /* we dont't want all given attributes and functions to appear in the
    _instances_ of our new class, so we temporarily store the code in a
    hash, remove all attributes that will be used for "meta" purposes
    (i.e. relation definitions and URL hints) and create the new class'
    prototype from the remainder. */

  if (Object.isUndefined(sub_class_code)) { // no inheritance (that is, except from ActiveResource.)
    var subClassCode = $H(parent_or_class);
    var parentClass  = this;
  } else {
    var subClassCode = $H(sub_class_code); // inherit from other Class
    var parentClass  = parent_or_class;
  }

  var habtm_relations      = $H(subClassCode.unset('has_and_belongs_to_many')); // not used, yet
  var belongs_to_relations = $H(subClassCode.unset('belongs_to'));
  var has_one_relations    = $H(subClassCode.unset('has_one'));
  var has_many_relations   = $H(subClassCode.unset('has_many'));
  var resource             = subClassCode.get('resource');
  var className            = resource.toClassName();

  /* klass holds a reference to the actual class,
     i.e. NOT its prototype */
  var klass = Class.create(parentClass, subClassCode.toObject());
  klass.prototype.className = className;

  /* it is possible, to define class methods for a class.
     They can defined using
        myClass.myMethod= function(...) {...};...
     or, to DRY things up a little, using
        MyClass.Class = {myMethod: function(...){...}, ...
     The MyClass.Class-"Module" will be mixed in here. */
  if (parentClass.Class) Object.extend(klass, parentClass.Class);

  ActiveResource.objectCache.set(className, $H());
  Object.extend(klass, {
//     objectCache: ActiveResource.objectCache.get(className),
    resource:    resource,
    className:   className
  });

  var association_types = ['has_one', 'has_many', 'belongs_to'];
  for (j=0; j<3; j++) {
    var assoc = association_types[j];
    eval('klass.%s_relations = %s_relations'.gsub('%s', assoc));
    var relation_names = eval(assoc+'_relations.keys()');
    for (var i = 0; i < relation_names.length; i++) {
      var relation_name = relation_names[i];
      var relation      = eval('klass.%s_relations.get(relation_name)'.sub('%s', assoc));
      relation.name = relation_name;
      eval('this.generate%sRelation(relation, klass)'.sub('%s', assoc.toClassName()));
    }
  }
  return klass;
};

ActiveResource.generateHasManyRelation = function(relation, klass) {
  relation.class_name = relation.class_name || relation.name.toClassName();
  relation.resource   = relation.resource   || relation.name;
  eval(
    ("Object.extend(klass.prototype, {" +
      // e.g. BlogPost.comments_url()
      "%rn_url: function(nix) {" +
        "if (nix) alert('You called %rn_url() with an argument, I bet you intended to call %rns_url()!');" +
        "return this.url() + '/" + relation.resource + "';" +
      "}," +
      // e.g. BlogPost.comment_url(id)
      "%rns_url: function(id) {" +
        "return this.url() + '/" + relation.resource + "/' + id;" +
      "}," +
      // e.g. BlogPost.comments()
      "%rn: function(reload_from_server) {" +
        "if (!this.new_record && (reload_from_server || !this.%rcn_instances)) {" +
          "this.%rcn_instances = %rcn.findByUrl(this.%rn_url() + '.json') || [];" +
//           "debug('RESPONSE to "+klass.className+"#"+relation.name+"_url(): ' + list);" +
        "} else if (!this.%rcn_instances) {" +
          "this.%rcn_instances = [];" +
        "} " +
        "return this.%rcn_instances;" +
      "}," +
      // e.g. BlogPost.comment(id)
      "%rns: function(id) {" +
        "var existing_element = ActiveResource.objectCache.get('%rcn').get(id.toString());" +
        "if (existing_element) {" +
//           "debug('CACHE HIT for " + klass.className + "#" + relation.name + "()');" +
          "return existing_element;" +
        "}" +
        "var list = %rcn.findByUrl(this.%rn_url() + '/' + id + '.json');" +
//         "debug('RESPONSE to " + klass.className + "#" + relation.name + "_url(): ' + list);" +
        "return list;" +
      "}" +
    "})").gsub('%rcn', relation.class_name).gsub('%rns', relation.name.singularize()).gsub('%rn', relation.name)
  );
}

ActiveResource.generateHasOneRelation = function(relation, klass) {
  relation.class_name = relation.class_name || relation.name.toClassName();
  relation.resource   = relation.resource   || relation.name.pluralize();
  eval(
    "Object.extend(klass.prototype, {" +
      // e.g. BlogPost.author_url()
      relation.name + "_url: function() { return this.url() + '/" + relation.resource + "'; }," +
      // e.g. BlogPost.author()
      relation.name + ": function() {" +
        "var existing_element = ActiveResource.objectCache.get('" + relation.class_name + "').get(this.get(" + relation.name + "_id).toString());" +
        "if (existing_element) return existing_element;" +
        "var resp = " + relation.class_name + ".findByUrl(this." + relation.name + "_url() + '.json');" +
        "debug('RESPONSE to " + klass.className + "#" + relation.name + "_url(): ' + resp);" +
        "return resp;" +
      "}" +
    "})"
  );
}

ActiveResource.generateBelongsToRelation = function(relation, klass) {
  relation.class_name = relation.class_name || relation.name.toClassName();
  relation.resource   = relation.resource   || relation.name.pluralize();
  eval(
    ("Object.extend(klass.prototype, {" +
      // e.g. Comment.blog_post_url()
      "%rn_url: function() {" +
        "return %rcn.element_url(this.get('%rn_id'));" +
      "}," +
      // e.g. Comment.blog_post()
      "%rn: function() {" +
//         "debug(this.className + '#%rn()');" +
        "if (!this.cached_%rn) {" +
          "this.cached_%rn = %rcn.findOne(this.get('%rn_id'));" +
        "}" +
        "return this.cached_%rn;" +
      "}" +
    "})").gsub('%rn', relation.name).gsub('%rcn', relation.class_name)
  );
}
