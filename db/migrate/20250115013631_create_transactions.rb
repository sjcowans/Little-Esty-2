class CreateTransactions < ActiveRecord::Migration[6.1]
  def change
    create_table :transactions do |t|
      t.references :invoice, foreign_key: true, required: true
      t.integer :credit_card_number
      t.date :credit_card_expiration_date
      t.integer :result
      t.timestamps
    end
  end
end