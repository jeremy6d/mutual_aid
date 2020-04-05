class AddUrgentToAidRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_requests, :urgent, :boolean, default: false
  end
end
