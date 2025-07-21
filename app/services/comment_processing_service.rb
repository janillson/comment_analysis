class CommentProcessingService
  def initialize(comment)
    @comment = comment
  end

  def call
    return unless @comment.created?

    @comment.process!

    translate_comment
    classify_comment

    @comment.save
  end

  private

  def translate_comment
    @comment.body = Translate.translate(@comment.original_body, :pt)
  end

  def classify_comment
    keywords = Keyword.pluck(:word).map(&:downcase)
    comment_words = @comment.body.downcase.split(/\W+/)

    matches = comment_words.count { |word| keywords.include?(word) }
    @comment.matched_keywords_count = matches

    if matches >= 2
      @comment.approve!
    else
      @comment.reject!
    end
  end
end
