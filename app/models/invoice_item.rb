class InvoiceItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :item
  
  enum status: { shipped: 1, packaged: 2, pending: 3}

  validates :invoice_id, :item_id, :quantity, :unit_price, :status, :created_at, presence: true
end
