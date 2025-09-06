class OrdersController < ApplicationController
  before_action :set_order, only: %i[ show ]

  def index
    render json: OrderSerializer.new(Order.all.page(params[:page])).serializable_hash
  end

  def show
    render json: OrderSerializer.new(@order).serializable_hash
  end

  def create
    order = Order.new(order_params)

    if order.transactional_save
      render json: OrderSerializer.new(order).serializable_hash, status: :created
    else
      json_errors(order.errors, :unprocessable_content)
    end
  end

  private
    def set_order
      @order = Order.find(params.expect(:id))
    end

    def order_params
      params.expect(order: [ order_items_attributes: [ [ :product_id, :qty ] ] ])
    end
end
