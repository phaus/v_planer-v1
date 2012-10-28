class Invoice < ActiveRecord::Base

  has_many :items,
      :class_name => 'InvoiceItem'

  belongs_to :client

  belongs_to :user

  belongs_to :company

  belongs_to :sender,
      :class_name => 'CompanySection'

  belongs_to :process,
    :polymorphic => true

  accepts_nested_attributes_for :items,
    :allow_destroy => true

  monetary_value :price

  def net_total_price
    self.price / 1.19
  end

  def to_pdf
    PdfInvoice.new(self).to_s
  end

  def remarks
    str = self.read_attribute(:remarks) || self.sender.text[:rental_bottom_text]
    str.gsub(/(%[a-z_]+)/) do |match|
      {'%payment_goal' => self.client.payment_goal, '%sender_name' => self.user.full_name}[match]
    end
  end

  def before_destroy
    self.process.remove_invoice! rescue nil
  end

  def before_save
    self.company = self.sender.company
  end

end
