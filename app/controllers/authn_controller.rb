class AuthnController < ApplicationController
  before_action :authenticate_user!, only: [:checkme]

  def whoami
    render json: current_user || {}
  end

  def checkme
    render json: current_user || {}
  end
end
