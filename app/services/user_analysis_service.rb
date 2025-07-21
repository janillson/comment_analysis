class UserAnalysisService
  def initialize(username)
    @username = username
    @user = nil
  end

  def call
    Rails.cache.fetch("user_analysis_#{@username}", expires_in: 30.minutes) do
      import_user_data
      process_comments_async
      calculate_metrics
      UserResponseBuilderService.new(@user).call
    end
  end

  private

  def import_user_data
    # Importa usuário, posts e comentários da JSONPlaceholder
    @user = JsonPlaceholderImportService.new(@username).call
  end

  def process_comments_async
    # Enfileira processamento de comentários
    @user.comments.created.find_each do |comment|
      ProcessCommentJob.perform_async({ "comment_id" => comment.id})
    end
  end

  def calculate_metrics
    # Calcula métricas após processamento
    CalculateUserMetricsJob.perform_async({"user_id" => @user.id})
    CalculateGroupMetricsJob.perform_async
  end

  def build_response
    # Constrói resposta JSON final
    UserResponseBuilderService.new(@user).call
  end
end
