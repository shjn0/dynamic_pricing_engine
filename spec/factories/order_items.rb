FactoryBot.define do
  factory :order_item do
    association :product
    qty { 1 }
    price_per_item { product.dynamic_price }
  end
end
