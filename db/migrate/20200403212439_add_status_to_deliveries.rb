class AddStatusToDeliveries < ActiveRecord::Migration[6.0]
  def change
    add_column :deliveries, :status, :string
  end
end
