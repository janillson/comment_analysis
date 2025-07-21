class ProcessCommentJob < ApplicationJob
  queue_as :default

  def perform(comment_id)
    comment = Comment.find(comment_id)
    CommentProcessingService.new(comment).call
  end
end
