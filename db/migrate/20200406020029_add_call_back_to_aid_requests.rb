class AddCallBackToAidRequests < ActiveRecord::Migration[6.0]
  def change
    add_column :aid_requests, :call_back, :boolean, default: false
  end
end
