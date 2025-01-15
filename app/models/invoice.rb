class Invoice < ApplicationRecord
  belongs_to :customer

  has_many :transactions, dependent: :destroy
  has_many :invoice_items, dependent: :destroy
  
  enum status: { completed: 1, in_progress: 2, cancelled: 3}

  validates :status, :customer_id, :created_at, presence: true
end
