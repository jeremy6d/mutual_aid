class CreateNotes < ActiveRecord::Migration[6.0]
  def change
    rename_column :fulfillments, :notes, :packing_notes
    create_table :notes do |t|
      t.bigint  :noteable_id
      t.string  :noteable_type
      t.belongs_to :author, foreign_key: { to_table: :volunteers }
      t.text :body

      t.timestamps
    end
    add_index :notes, [:noteable_type, :noteable_id]
  end
end
