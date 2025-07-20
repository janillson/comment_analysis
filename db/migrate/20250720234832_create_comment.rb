class CreateComment < ActiveRecord::Migration[7.0]
  def change
    create_table :comments do |t|
      t.references :post, null: false, foreign_key: true
      t.text :original_body, null: false
      t.text :body
      t.string :status, default: "created"
      t.integer :matched_keywords_count, default: 0
      t.integer :external_id, null: false

      t.timestamps
    end

    add_index :comments, :external_id, unique: true
    add_index :comments, :status
  end
end
