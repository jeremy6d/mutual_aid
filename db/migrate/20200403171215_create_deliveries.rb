class CreateDeliveries < ActiveRecord::Migration[6.0]
  def change
    create_table :deliveries do |t|
      t.string :notes
      t.belongs_to :driver, foreign_key: { to_table: :volunteers }
      t.timestamps
    end

    add_reference :fulfillments, :delivery
  end
end
