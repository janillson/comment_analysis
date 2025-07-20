class CreateUser < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :name
      t.string :email
      t.integer :external_id, null: false

      t.timestamps
    end

    add_index :users, :username, unique: true
    add_index :users, :external_id, unique: true
  end
end
