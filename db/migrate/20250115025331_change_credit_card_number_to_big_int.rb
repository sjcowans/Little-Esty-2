class ChangeCreditCardNumberToBigInt < ActiveRecord::Migration[6.1]
  def change
    change_column :transactions, :credit_card_number, :bigint
  end
end
