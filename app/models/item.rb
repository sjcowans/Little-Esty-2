class Item < ApplicationRecord
  belongs_to :merchant
  
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items

  validates :name, :description, :unit_price, :merchant_id, :created_at, presence: true
end
