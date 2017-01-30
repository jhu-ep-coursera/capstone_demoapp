class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  #make the connection between controller action and associated view
  include ActionController::ImplicitRender
  include Pundit

  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from Mongoid::Errors::DocumentNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :missing_parameter
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected
    def full_message_error full_message, status
      payload = {
        errors: { full_messages:["#{full_message}"] }
      }
      render :json=>payload, :status=>status
    end
    def record_not_found(exception) 
      full_message_error "cannot find id[#{params[:id]}]", :not_found
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

    def user_not_authorized(exception)
      user=pundit_user ? pundit_user.uid : "Anonymous user"
      payload = {
        errors: {full_messages:["#{user} not authorized to #{exception.query}"]}
      }
      render :json=>payload, :status=>:forbidden
      Rails.logger.debug exception
    end
end
