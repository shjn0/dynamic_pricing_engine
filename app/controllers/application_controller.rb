class ApplicationController < ActionController::API
  rescue_from Mongoid::Errors::DocumentNotFound, with: :document_not_found

  def document_not_found(e)
    render json: { error: I18n.t("errors.not_found", class: e.klass) }, status: :not_found
  end

  def json_errors(messages, status)
    render json: { errors: [ messages ] }, status: status
  end
end
