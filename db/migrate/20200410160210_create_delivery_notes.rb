class CreateDeliveryNotes < ActiveRecord::Migration[6.0]
  def change
    create_table :delivery_notes do |t|
      t.belongs_to :fulfillment
      t.belongs_to :delivery
      t.text :note

      t.timestamps
    end
  end
end
