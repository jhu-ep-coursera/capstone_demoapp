class AddFooNameConstraint < ActiveRecord::Migration
  def up
    change_column :foos, :name, :string, {null: false}
  end
  def down
    change_column :foos, :name, :string, {null: true}
  end
end
