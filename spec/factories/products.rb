FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    category { "Sample Category" }
    default_price { BigDecimal("1000.00") }
    dynamic_price { BigDecimal("1000.00") }
    qty { 100 }
  end
end
