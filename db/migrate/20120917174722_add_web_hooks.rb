class AddWebHooks < ActiveRecord::Migration
  def change
    create_table :web_hooks do |t|
      t.boolean :secure
      t.string :event
      t.string :url
      t.timestamps
    end
  end
end
