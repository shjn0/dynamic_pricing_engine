class OrderSerializer < ApplicationSerializer
  attribute :order_items do |order|
    OrderItemSerializer.new(order.order_items).serializable_hash
  end

  attribute :total_price
end
