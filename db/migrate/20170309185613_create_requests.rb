class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.references :user, index: true	
      t.string :stop_id
      t.string :line_id
      t.timestamps null: false
    end
  end
end
