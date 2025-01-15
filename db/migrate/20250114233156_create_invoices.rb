class CreateInvoices < ActiveRecord::Migration[6.1]
  def change
    create_table :invoices do |t|
      t.integer :status
      t.references :customer, foreign_key: true, required: true
      t.timestamps
    end
  end
end
