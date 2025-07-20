class CreateKeyword < ActiveRecord::Migration[7.0]
  def change
    create_table :keywords do |t|
      t.string :word, null: false

      t.timestamps
    end

    add_index :keywords, :word, unique: true
  end
end
