class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.references :user, {index: true, foreign_key: true, null:false}
      t.string :role_name, {null: false}
      t.string :mname, {index:true}
      t.integer :mid,  {index:true}

      t.timestamps null: false
    end
    add_index :roles, [:mname, :mid]
  end
end
