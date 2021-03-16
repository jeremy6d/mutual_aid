class AddNeighborhoodsToDelivery < ActiveRecord::Migration[6.0]
  def up
    add_column :deliveries, :neighborhoods, :text
    Delivery.all.each do |d| 
      d.send(:cache_neighborhoods!)
      d.save(touch: false)
    end
  end

  def down
    remove_column :deliveries, :neighborhoods
  end
end
