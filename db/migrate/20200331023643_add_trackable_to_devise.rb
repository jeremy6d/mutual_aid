class AddTrackableToDevise < ActiveRecord::Migration[6.0]
  def up
    add_column :volunteers, :sign_in_count, :integer, default: 0, null: false
    add_column :volunteers, :current_sign_in_at, :datetime
    add_column :volunteers, :last_sign_in_at, :datetime
    add_column :volunteers, :current_sign_in_ip, :inet
    add_column :volunteers, :last_sign_in_ip, :inet
  end

  def down
    remove_columns :volunteers, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip
  end
end
