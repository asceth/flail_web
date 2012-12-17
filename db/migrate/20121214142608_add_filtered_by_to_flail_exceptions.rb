class AddFilteredByToFlailExceptions < ActiveRecord::Migration
  def change
    add_column :flail_exceptions, :filtered_by, :integer
  end
end
