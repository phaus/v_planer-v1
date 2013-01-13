var Product = ActiveResource.inherit({
  has_many: {
    'rental_periods': {}
  },
  belongs_to: {
    'company_section': {}
  },
  resource: 'products',

  isAvailable: function(from_date, to_date) {
    if (typeof(from_date) != 'object')
      from_date = new Date(from_date);
    if (typeof(to_date) != 'object')
      to_date = new Date(to_date);

    var unavailabilities = this.rental_periods();
    for (var i=0, len=unavailabilities.length; i<len; i++) {
      unav = unavailabilities[i];
      if (unav.from_date < to_date && unav.to_date > from_date) return false;
    }
    return true;
  },

  unit_price: function() {
    if (this.is_rentable())
      return $M(this.get('article').rental_price);
    else if (this.is_sellable())
      return $M(this.get('article').selling_price);
    else if (this.is_service())
      return $M(this.get('article').unit_price);
    else
      return $M(0);
  },

  rental_price: function() {
    return $M(this.get('article').rental_price || 0);
  },

  selling_price: function() {
    return $M(this.get('article').selling_price || 0);
  },

  is_rentable: function() {
    return !!this.get('article').rental_price;
  },

  is_sellable: function() {
    return !!this.get('article').selling_price;
  },

  is_service: function() {
    return this.get('article_type') == 'Service'
  }

});
