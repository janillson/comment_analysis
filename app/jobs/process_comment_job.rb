class ProcessCommentJob
  include Sidekiq::Job

  sidekiq_options queue: :default

  def perform(args)
    comment_id = args["comment_id"]
    comment = Comment.find(comment_id)
    CommentProcessingService.new(comment).call
  end
end
