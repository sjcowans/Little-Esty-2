class Customer < ApplicationRecord
  has_many :invoices, dependent: :destroy

  validates :first_name, :last_name, presence: true
  validates :created_at, :updated_at, presence: true
end
