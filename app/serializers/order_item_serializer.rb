class OrderItemSerializer < ApplicationSerializer
  attributes :product_id, :qty, :price_per_item, :total_price
end
