class AddPublicIdToFulfillment < ActiveRecord::Migration[6.0]
  def up
    add_column :fulfillments, :public_id, :string
  end
end
