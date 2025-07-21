class Api::V1::AnalysisController < ApplicationController
  def analyze_user
    username = params[:username]

    if username.blank?
      render json: { error: 'Username é obrigatório' }, status: :bad_request

      return
    end

    result = UserAnalysisService.new(username).call

    if result
      render json: result
    else
      render json: { error: 'Usuário não encontrado' }, status: :not_found
    end
  end
end
