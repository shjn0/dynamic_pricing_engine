class UpdatePriceJob < ApplicationJob
  queue_as :default

  def perform(product_id, competitor_product)
    DynamicPricingService.new(product_id, competitor_product).call
  end
end
