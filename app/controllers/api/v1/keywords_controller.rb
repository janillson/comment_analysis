class Api::V1::KeywordsController < ApplicationController
  def index
    render json: { keywords: Keyword.all.pluck(:word) }
  end

  def create
    keyword = Keyword.new(keyword_params)

    if keyword.save
      render json: { message: 'Palavra-chave adicionada com sucesso' }
    else
      render json: { errors: keyword.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    word = params[:word]&.to_s&.downcase&.strip

    keyword = Keyword.where('LOWER(word) = ?', word).first

    return render json: { message: 'Palavra-chave não encontrada' }, status: :not_found if keyword.nil?

    keyword.destroy

    render json: { message: 'Palavra-chave removida com sucesso' }
  end

  private

  def keyword_params
    params.permit(:word)
  end
end