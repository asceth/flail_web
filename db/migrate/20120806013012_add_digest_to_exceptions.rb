class AddDigestToExceptions < ActiveRecord::Migration
  def change
    add_column :flail_exceptions, :digest, :string
  end
end
