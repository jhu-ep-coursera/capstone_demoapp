class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :update, :destroy]
  wrap_parameters :image, include: ["caption"]
  before_action :authenticate_user!, only: [:create, :update, :destroy]
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: [:index]

  def index
    authorize Image
    @images = policy_scope(Image.all)
  end

  def show
  end

  def create
    authorize Image
    @image = Image.new(image_params)
    @image.creator_id=current_user.id

    if @image.save
      render :show, status: :created, location: @image
    else
      render json: {errors:@image.errors.messages}, status: :unprocessable_entity
    end
  end

  def update
    @image = Image.find(params[:id])

    if @image.update(image_params)
      head :no_content
    else
      render json: {errors:@image.errors.messages}, status: :unprocessable_entity
    end
  end

  def destroy
    @image.destroy

    head :no_content
  end

  private

    def set_image
      @image = Image.find(params[:id])
    end

    def image_params
      params.require(:image).permit(:caption)
    end
end
