class ThingImagesController < ApplicationController
  wrap_parameters :thing_image, include: ["image_id", "thing_id", "priority"]
  before_action :get_thing, only: [:index, :update, :destroy]
  before_action :get_thing_image, only: [:update, :destroy]
  before_action :authenticate_user!, only: [:create, :update, :destroy]

  def index
    @thing_images = @thing.thing_images.prioritized.with_caption
  end

  def image_things
    image = Image.find(params[:image_id])
    @thing_images=image.thing_images.prioritized.with_name
    render :index 
  end

  def linkable_things
    image = Image.find(params[:image_id])
    @things=current_user ? Thing.not_linked(image) : []
    render "things/index"
  end

  def create
    thing_image = ThingImage.new(thing_image_create_params.merge({
                                  :image_id=>params[:image_id],
                                  :thing_id=>params[:thing_id],
                                  }))
    if !Thing.where(id:thing_image.thing_id).exists?
      full_message_error "cannot find thing[#{params[:thing_id]}]", :bad_request
    elsif !Image.where(id:thing_image.image_id).exists?
      full_message_error "cannot find image[#{params[:image_id]}]", :bad_request
    end

    thing_image.creator_id=current_user.id
    if thing_image.save
      head :no_content
    else
      render json: {errors:@thing_image.errors.messages}, status: :unprocessable_entity
    end
  end

  def update
    if @thing_image.update(thing_image_update_params)
      head :no_content
    else
      render json: {errors:@thing_image.errors.messages}, status: :unprocessable_entity
    end
  end

  def destroy
    @thing_image.destroy
    head :no_content
  end

  private
    def get_thing
      @thing ||= Thing.find(params[:thing_id])
    end
    def get_thing_image
      @thing_image ||= ThingImage.find(params[:id])
    end

    def thing_image_create_params
      params.require(:thing_image).tap {|p|
          #_ids only required in payload when not part of URI
          p.require(:image_id)    if !params[:image_id]
          p.require(:thing_id)    if !params[:thing_id]
        }.permit(:priority, :image_id, :thing_id)
    end
    def thing_image_update_params
      params.require(:thing_image).permit(:priority)
    end
end
