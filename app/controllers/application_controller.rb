class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :use_logidze_responsible, only: %i[create update destroy]

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
  end

  def use_logidze_responsible(&block)
    Logidze.with_responsible(current_volunteer&.id, &block)
  end
end
