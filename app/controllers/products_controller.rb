class ProductsController < ApplicationController
  before_action :set_product, only: %i[ show ]

  def index
    render json: ProductSerializer.new(Product.all.page(params[:page])).serializable_hash
  end

  def show
    render json: ProductSerializer.new(@product).serializable_hash
  end

  private
    def set_product
      @product = Product.find(params.expect(:id))
    end
end
