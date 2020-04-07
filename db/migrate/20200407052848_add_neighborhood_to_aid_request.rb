class AddNeighborhoodToAidRequest < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_requests, :neighborhood, :string
  end
end
