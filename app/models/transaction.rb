class Transaction < ApplicationRecord
  belongs_to :invoice
  enum status: { failed: 2, success: 1}
end
