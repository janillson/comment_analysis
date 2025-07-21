class CreateGroupMetric < ActiveRecord::Migration[7.0]
  def change
    create_table :group_metrics do |t|
      t.integer :total_users, default: 0
      t.integer :total_comments, default: 0
      t.decimal :overall_approval_rate, precision: 5, scale: 2, default: 0.0
      t.decimal :average_comments_per_user, precision: 8, scale: 2, default: 0.0
      t.decimal :median_comments_per_user, precision: 8, scale: 2, default: 0.0
      t.decimal :std_dev_comments_per_user, precision: 8, scale: 2, default: 0.0

      t.timestamps
    end
  end
end
