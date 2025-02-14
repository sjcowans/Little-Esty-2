class CreateItems < ActiveRecord::Migration[6.1]
  def change
    create_table :items do |t|
      t.string :name
      t.text :description
      t.decimal :unit_price
      t.references :merchant, foreign_key: true, required: true
      t.timestamps
    end
  end
end