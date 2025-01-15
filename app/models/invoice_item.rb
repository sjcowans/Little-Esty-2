class InvoiceItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :item
  enum status: { shipped: 1, packaged: 2, pending: 3}
end
