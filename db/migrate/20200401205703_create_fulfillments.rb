class CreateFulfillments < ActiveRecord::Migration[6.0]
  def change
    create_table :fulfillments do |t|
      t.belongs_to :fulfiller, foreign_key: { to_table: :volunteers }
      t.belongs_to :aid_request
      t.text :contents
      t.text :notes
      t.string :status
      t.integer :num_bags, default: 1

      t.timestamps
    end
  end
end
