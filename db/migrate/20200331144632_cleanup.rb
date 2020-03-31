class Cleanup < ActiveRecord::Migration[6.0]
  def change
    add_reference :aid_requests, :original_taker, foreign_key: { to_table: :volunteers }
    remove_column :aid_requests, :volunteer_name, :string
  end
end
