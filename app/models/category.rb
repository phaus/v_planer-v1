class Category < ActiveRecord::Base
  include CompanySectionSpecifics

  has_and_belongs_to_many :products
  belongs_to :company_section

  attr_protected :company_section_id

  validates_presence_of :name,
      :company_section

  scope :not_empty, lambda {|*scope|
  selection = select('distinct(categories.id), categories.name')
    case scope.first.to_s
    when 'sellable'
#       selection.joins(%q(JOIN categories_products ON categories_products.category_id = categories.id RIGHT OUTER JOIN (SELECT products.id AS prodid FROM products JOIN devices ON devices.id = products.article_id and products.article_type = 'Device' WHERE devices.selling_price_i IS NOT NULL) AS prods ON prods.prodid = categories_products.product_id))
      selection.joins(:categories_products)
    when 'rentable'
#       selection.joins(%q(JOIN categories_products ON categories_products.category_id = categories.id RIGHT OUTER JOIN (SELECT products.id AS prodid FROM products JOIN devices ON devices.id = products.article_id and products.article_type = 'Device' WHERE devices.rental_price_i IS NOT NULL) AS prods ON prods.prodid = categories_products.product_id))
      selection.joins(:categories_products)
    when 'service'
#       selection.joins(%q(JOIN categories_products ON categories_products.category_id = categories.id RIGHT OUTER JOIN (SELECT products.id AS prodid FROM products JOIN services ON services.id = products.article_id and products.article_type = 'Service') AS services ON services.prodid = categories_products.product_id))
      selection.joins(:categories_products)
    else
      selection.joins(:products)
    end
  }
end
