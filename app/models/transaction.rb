class Transaction < ApplicationRecord
  belongs_to :invoice

  enum status: { failed: 2, success: 1}

  validates :invoice_id, :credit_card_number, :result, :created_at, presence: true
end
