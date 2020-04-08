class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  around_action :use_logidze_responsible, only: %i[create update destroy]

  protected

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || resource.approved? ? aid_requests_path : root_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone_number])
  end

  def use_logidze_responsible(&block)
    if volunteer_signed_in?
      Logidze.with_responsible(current_volunteer&.id, &block)
    else
      yield block
    end
  end
end
