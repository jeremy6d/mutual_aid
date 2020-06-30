class CreatePackingSlips < ActiveRecord::Migration[6.0]
  def change
    create_table :packing_slips do |t|
      t.string :creator_name
      t.belongs_to :creator, foreign_key: { to_table: :volunteers }
      t.text :remarks
      t.timestamps
    end
    add_reference :fulfillments, :packing_slip
    add_column    :fulfillments, :special,  :boolean, default: false
    remove_column :fulfillments, :packing_notes,    :text
    remove_column :fulfillments, :num_bags, :integer
    
    puts AidRequest.where(call_back: true).
               update_all(status: 'call_back')
    puts AidRequest.where(status: "unfulfilled").
                    update_all(status: 'fresh')
# should have run "create_fulfillments!" manually on fresh ones

    puts AidRequest.where(status: "in_progress").
               select { |ar| ar.fulfillments.empty? }.
               each { |ar| ar.send :create_fulfillments! }
    puts AidRequest.where(status: "fulfilled").
               update_all(status: "complete")
AidRequest.fresh.each &:start!
    remove_column :aid_requests, :call_back, :boolean
  end
end
