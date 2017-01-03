class CreateThingImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :caption
      t.integer :creator_id, {null:false}

      t.timestamps null: false
    end

    create_table :things do |t|
      t.string :name, {null: false}
      t.text :description
      t.text :notes

      t.timestamps null: false
    end

    create_table :thing_images do |t|
      t.references :image, {index: true, foreign_key: true, null:false}
      t.references :thing, {index: true, foreign_key: true, null:false}
      t.integer :priority, {null:false, default:5}
      t.integer :creator_id, {null:false}

      t.timestamps null: false
    end

    add_index :images, :creator_id
    add_index :things, :name
    add_index :thing_images, [:image_id, :thing_id], unique:true
  end
end
