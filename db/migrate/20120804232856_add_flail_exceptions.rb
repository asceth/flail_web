class AddFlailExceptions < ActiveRecord::Migration
  def change
    create_table :flail_exceptions do |t|
      t.string :target_url
      t.string :referer_url
      t.string :user_agent
      t.string :class_name

      t.string :environment
      t.string :hostname
      t.string :tag

      t.text :user
      t.text :rack
      t.text :params
      t.text :message
      t.text :backtrace

      t.datetime :resolved_at
      t.timestamps
    end

    add_index :flail_exceptions, [:created_at]
    add_index :flail_exceptions, [:resolved_at]
    add_index :flail_exceptions, [:tag]
    add_index :flail_exceptions, [:environment]
  end
end
