class AddSpecialRequestsToAidRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_requests, :special_requests, :text
  end
end
