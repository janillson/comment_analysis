class AddUserIdToComments < ActiveRecord::Migration[7.0]
  def up
    add_reference :comments, :user, null: true, foreign_key: true

    Comment.reset_column_information
    Comment.includes(:post).find_each(batch_size: 1000) do |comment|
      comment.update_column(:user_id, comment.post.user_id) if comment.post
    end

    change_column_null :comments, :user_id, false
  end

  def down
    remove_reference :comments, :user, foreign_key: true
  end
end
