class CreateUserMetric < ActiveRecord::Migration[7.0]
  def change
    create_table :user_metrics do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :total_comments, default: 0
      t.integer :approved_comments, default: 0
      t.integer :rejected_comments, default: 0
      t.decimal :approval_rate, precision: 5, scale: 2, default: 0.0
      t.decimal :average_comment_length, precision: 8, scale: 2, default: 0.0
      t.decimal :median_comment_length, precision: 8, scale: 2, default: 0.0
      t.decimal :std_dev_comment_length, precision: 8, scale: 2, default: 0.0

      t.timestamps
    end
  end
end
