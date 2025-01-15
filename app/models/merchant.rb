class Merchant < ApplicationRecord
  has_many :items, dependent: :destroy
  
  validates :name, :created_at, presence: true
end
