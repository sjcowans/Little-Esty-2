class CreateInvoiceItems < ActiveRecord::Migration[6.1]
  def change
    create_table :invoice_items do |t|
      t.references :invoice, foreign_key: true, required: true
      t.references :item, foreign_key: true, required: true
      t.integer :quantity
      t.decimal :unit_price
      t.integer :status
      t.timestamps
    end
  end
end