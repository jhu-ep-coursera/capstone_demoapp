class ImagesController < ApplicationController
  before_action :set_image, only: [:show, :update, :destroy, :content]
  wrap_parameters :image, include: ["caption"]
  before_action :authenticate_user!, only: [:create, :update, :destroy]
  after_action :verify_authorized, except: [:content]
  after_action :verify_policy_scoped, only: [:index]

  def index
    authorize Image
    @images = policy_scope(Image.all)
    @images = ImagePolicy.merge(@images)
  end

  def show
    authorize @image
    images = policy_scope(Image.where(:id=>@image.id))
    @image = ImagePolicy.merge(images).first
  end

  def content
    result=ImageContent.image(@image).smallest.first
    if result
      options = { type: result.content_type,
                  disposition: "inline",
                  filename: "#{@image.basename}.#{result.suffix}" }
      send_data result.content.data, options
    else
      render nothing: true, status: :not_found
    end
  end

  def create
    authorize Image
    @image = Image.new(image_params)
    @image.creator_id=current_user.id

    User.transaction do
      if @image.save
        original=ImageContent.new(image_content_params)
        contents=ImageContentCreator.new(@image, original).build_contents
        if (contents.save!) 
          role=current_user.add_role(Role::ORGANIZER, @image)
          @image.user_roles << role.role_name
          role.save!
          render :show, status: :created, location: @image
        end
      else
        render json: {errors:@image.errors.messages}, status: :unprocessable_entity
      end
    end
  end

  def update
    authorize @image

    if @image.update(image_params)
      head :no_content
    else
      render json: {errors:@image.errors.messages}, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @image
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

    def image_content_params
      params.require(:image_content).tap { |ic|
        ic.require(:content_type)
        ic.require(:content)
      }.permit(:content_type, :content)
    end
end
