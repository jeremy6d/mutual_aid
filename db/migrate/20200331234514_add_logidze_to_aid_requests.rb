class AddLogidzeToAidRequests < ActiveRecord::Migration[5.0]
  require 'logidze/migration'
  include Logidze::Migration

  def up
    
    add_column :aid_requests, :log_data, :jsonb
    

    execute <<-SQL
      CREATE TRIGGER logidze_on_aid_requests
      BEFORE UPDATE OR INSERT ON aid_requests FOR EACH ROW
      WHEN (coalesce(#{current_setting('logidze.disabled')}, '') <> 'on')
      EXECUTE PROCEDURE logidze_logger(null, 'updated_at');
    SQL

    
  end

  def down
    
    execute "DROP TRIGGER IF EXISTS logidze_on_aid_requests on aid_requests;"

    
    remove_column :aid_requests, :log_data
    
    
  end
end
