class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  #make the connection between controller action and associated view
  include ActionController::ImplicitRender
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from Mongoid::Errors::DocumentNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :missing_parameter

  protected
    def record_not_found(exception) 
      payload = {
        errors: { full_messages:["cannot find id[#{params[:id]}]"] }
      }
      render :json=>payload, :status=>:not_found
      Rails.logger.debug exception.message
    end

    def missing_parameter(exception) 
      payload = {
        errors: { full_messages:["#{exception.message}"] }
      }
      render :json=>payload, :status=>:bad_request
      Rails.logger.debug exception.message
    end

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    end 
end
