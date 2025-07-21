require 'sidekiq/api'
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

  def progress
    workers = Sidekiq::Workers.new
    jobs = []

    workers.each do |_process_id, _thread_id, work|
      payload = JSON.parse(work['payload'])

      jobs << {
        queue: work['queue'],
        class: payload['class'],
        args: payload['args'],
        run_at: Time.at(work['run_at'])
      }
    end

    render json: jobs
  end
end
