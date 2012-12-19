class AddFlailExceptionsCountToFilters < ActiveRecord::Migration
  def change
    add_column :filters, :flail_exceptions_count, :integer, :null => false, :default => 0
  end
end
