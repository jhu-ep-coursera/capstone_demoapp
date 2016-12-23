class FoosController < ApplicationController
  before_action :set_foo, only: [:show, :update, :destroy]
  wrap_parameters :foo, include: ["name"]

  def index
    @foos = Foo.all
    #render json: @foos
  end

  def show
    #render json: @foo
  end

  def create
    @foo = Foo.new(foo_params)

    if @foo.save
      #render json: @foo, status: :created, location: @foo
      render :show, status: :created, location: @foo
    else
      render json: @foo.errors, status: :unprocessable_entity
    end
  end

  def update
    @foo = Foo.find(params[:id])

    if @foo.update(foo_params)
      head :no_content
    else
      render json: @foo.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @foo.destroy

    head :no_content
  end

  private

    def set_foo
      @foo = Foo.find(params[:id])
    end

    def foo_params
      params.require(:foo).permit(:name)
    end
end
