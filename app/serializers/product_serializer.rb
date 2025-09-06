class ProductSerializer < ApplicationSerializer
  attributes :name, :category, :default_price, :dynamic_price, :qty
end
