var Client = ActiveResource.inherit({
  has_many: {
    'rental_periods': {},
  },

  resource: 'clients',

  discount: function() {
    return this.get('discount');
  }


});
